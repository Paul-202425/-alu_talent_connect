import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/firestore_field_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/startup_profile.dart';
import '../models/startup_profile_model.dart';

class StartupRemoteDataSource {
  StartupRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.startupsCollection);

  Stream<StartupProfile?> watchStartup(String startupId) {
    return _collection.doc(startupId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return StartupProfileModel.fromFirestore(snapshot).toEntity();
    });
  }

  Future<StartupProfile?> getStartup(String startupId) async {
    try {
      final snapshot = await _collection.doc(startupId).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return StartupProfileModel.fromFirestore(snapshot).toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load startup');
    }
  }

  Future<StartupProfile?> getStartupByFounder(String founderId) async {
    try {
      final snapshot =
          await _collection.where(FirestoreFields.founderId, isEqualTo: founderId).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      return StartupProfileModel.fromFirestore(snapshot.docs.first).toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load startup');
    }
  }

  Future<StartupProfile> createStartup({
    required String founderId,
    required String name,
    required String description,
    required String industry,
    int? teamSize,
    String? website,
  }) async {
    try {
      final docRef = _collection.doc();
      final model = StartupProfileModel(
        id: docRef.id,
        name: name,
        description: description,
        industry: industry,
        founderId: founderId,
        teamSize: teamSize,
        website: website,
      );
      await docRef.set(model.toFirestore(isCreate: true));
      final snapshot = await docRef.get();
      return StartupProfileModel.fromFirestore(snapshot).toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create startup');
    }
  }
}
