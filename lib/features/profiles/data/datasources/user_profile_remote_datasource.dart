import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/firestore_field_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileRemoteDataSource {
  UserProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<UserProfile?> watchProfile(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfileModel.fromFirestore(snapshot).toEntity();
    });
  }

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserProfileModel.fromFirestore(snapshot).toEntity();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to load profile');
    }
  }

  Future<void> linkStartup({required String userId, required String startupId}) async {
    try {
      await _firestore.collection(AppConstants.usersCollection).doc(userId).update({
        FirestoreFields.startupId: startupId,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to link startup');
    }
  }
}
