import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/firestore_field_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/enums/opportunity_type.dart';
import '../../domain/enums/work_location.dart';
import '../models/opportunity_model.dart';

class OpportunityRemoteDataSource {
  OpportunityRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.opportunitiesCollection);

  /// Real-time stream of active opportunities, newest first.
  Stream<List<Opportunity>> watchActiveOpportunities() {
    return _collection
        .where(FirestoreFields.isActive, isEqualTo: true)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  /// Real-time stream for a single opportunity document.
  Stream<Opportunity?> watchOpportunity(String id) {
    return _collection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return OpportunityModel.fromFirestore(snapshot).toEntity();
    });
  }

  Future<Opportunity?> getOpportunity(String id) async {
    try {
      final snapshot = await _collection.doc(id).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return OpportunityModel.fromFirestore(snapshot).toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load opportunity');
    }
  }

  /// Real-time list of a startup's own postings (active and inactive).
  Stream<List<Opportunity>> watchOpportunitiesByStartup(String startupId) {
    return _collection
        .where(FirestoreFields.startupId, isEqualTo: startupId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  Future<Opportunity> createOpportunity({
    required String startupId,
    required String startupName,
    required String title,
    required String description,
    required WorkLocation location,
    required OpportunityType type,
    required List<String> requiredSkills,
    required String duration,
  }) async {
    try {
      final docRef = _collection.doc();
      final model = OpportunityModel(
        id: docRef.id,
        title: title,
        description: description,
        startupId: startupId,
        startupName: startupName,
        location: location,
        type: type,
        requiredSkills: requiredSkills,
        duration: duration,
        isActive: true,
      );
      await docRef.set(model.toFirestore(isCreate: true));
      final snapshot = await docRef.get();
      return OpportunityModel.fromFirestore(snapshot).toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create opportunity');
    }
  }

  Future<void> setOpportunityActive({
    required String opportunityId,
    required bool isActive,
  }) async {
    try {
      await _collection.doc(opportunityId).update({
        FirestoreFields.isActive: isActive,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update opportunity');
    }
  }

  List<Opportunity> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => OpportunityModel.fromFirestore(doc).toEntity())
        .toList();
  }
}
