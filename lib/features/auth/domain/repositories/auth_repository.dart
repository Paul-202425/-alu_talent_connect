import '../../../profiles/domain/entities/user_profile.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  /// Stream of auth session changes. Firebase persists sessions automatically.
  Stream<AuthUser?> get authStateChanges;

  /// Synchronously returns the cached current user, if any.
  AuthUser? get currentUser;

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});
}
