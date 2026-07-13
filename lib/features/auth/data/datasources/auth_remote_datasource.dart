import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/firestore_field_names.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/auth_error_mapper.dart';
import '../../../profiles/domain/entities/user_profile.dart';
import '../../domain/entities/auth_user.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  AuthUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed. Please try again.');
      }
      return _mapFirebaseUser(user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.fromFirebaseAuthException(e));
    }
  }

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      await user.updateDisplayName(fullName.trim());

      await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set({
        FirestoreFields.email: email.trim().toLowerCase(),
        FirestoreFields.fullName: fullName.trim(),
        FirestoreFields.role: role.value,
        FirestoreFields.skills: <String>[],
        FirestoreFields.bookmarkedOpportunityIds: <String>[],
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });

      return AuthUser(
        id: user.uid,
        email: user.email ?? email.trim(),
        displayName: fullName.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.fromFirebaseAuthException(e));
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Failed to create user profile.');
    }
  }

  Future<void> signOut() async {
    // Subscribe before signing out so we don't race the auth-state stream:
    // signOut()'s Future can resolve before listeners (e.g. the router) see
    // the change, since they're delivered over a separate async channel.
    final signedOut = _firebaseAuth.authStateChanges().firstWhere((user) => user == null);
    await _firebaseAuth.signOut();
    await signedOut;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorMapper.fromFirebaseAuthException(e));
    }
  }

  AuthUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }
}
