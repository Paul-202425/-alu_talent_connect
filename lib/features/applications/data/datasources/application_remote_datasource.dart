import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/firestore_field_names.dart';
import '../../../../core/database/firestore_schema.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../domain/entities/application.dart';
import '../../domain/enums/application_status.dart';
import '../models/application_model.dart';

class ApplicationRemoteDataSource {
  ApplicationRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.applicationsCollection);

  Stream<List<Application>> watchStudentApplications(String applicantId) {
    return _collection
        .where(FirestoreFields.applicantId, isEqualTo: applicantId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc).toEntity())
            .toList());
  }

  Stream<List<Application>> watchStartupApplications(String startupId) {
    return _collection
        .where(FirestoreFields.startupId, isEqualTo: startupId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromFirestore(doc).toEntity())
            .toList());
  }

  Stream<Application?> watchApplicationForOpportunity({
    required String opportunityId,
    required String applicantId,
  }) {
    final docId = FirestoreSchema.applicationDocId(
      opportunityId: opportunityId,
      applicantId: applicantId,
    );

    return _collection.doc(docId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return ApplicationModel.fromFirestore(snapshot).toEntity();
    });
  }

  Future<bool> hasApplied({
    required String opportunityId,
    required String applicantId,
  }) async {
    final docId = FirestoreSchema.applicationDocId(
      opportunityId: opportunityId,
      applicantId: applicantId,
    );
    final snapshot = await _collection.doc(docId).get();
    return snapshot.exists;
  }

  /// Atomically creates application + increments opportunity counter.
  Future<Application> submitApplication({
    required Opportunity opportunity,
    required String applicantId,
    required String applicantName,
    required String applicantEmail,
    String? coverLetter,
  }) async {
    final applicationId = FirestoreSchema.applicationDocId(
      opportunityId: opportunity.id,
      applicantId: applicantId,
    );

    final applicationRef = _collection.doc(applicationId);
    final opportunityRef = _firestore
        .collection(AppConstants.opportunitiesCollection)
        .doc(opportunity.id);

    try {
      final model = ApplicationModel(
        id: applicationId,
        opportunityId: opportunity.id,
        opportunityTitle: opportunity.title,
        startupId: opportunity.startupId,
        startupName: opportunity.startupName,
        applicantId: applicantId,
        applicantName: applicantName,
        applicantEmail: applicantEmail,
        status: ApplicationStatus.pending,
        coverLetter: coverLetter?.trim().isEmpty ?? true ? null : coverLetter?.trim(),
      );

      await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(applicationRef);
        if (existing.exists) {
          throw const AuthException('You have already applied to this opportunity.');
        }

        final opportunitySnap = await transaction.get(opportunityRef);
        if (!opportunitySnap.exists) {
          throw const ServerException('This opportunity no longer exists.');
        }

        final isActive = opportunitySnap.data()?[FirestoreFields.isActive] as bool? ?? false;
        if (!isActive) {
          throw const ServerException('This opportunity is no longer accepting applications.');
        }

        transaction.set(applicationRef, model.toFirestore(isCreate: true));
        transaction.update(opportunityRef, {
          FirestoreFields.applicationCount: FieldValue.increment(1),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        });
      });

      final created = await applicationRef.get();
      return ApplicationModel.fromFirestore(created).toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to submit application');
    }
  }

  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    try {
      await _collection.doc(applicationId).update({
        FirestoreFields.status: status.value,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update application');
    }
  }
}
