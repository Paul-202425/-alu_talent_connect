import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../profiles/domain/entities/user_profile.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/enums/auth_status.dart';
import '../../domain/repositories/auth_repository.dart';
import '../state/auth_form_state.dart';

// ── Data layer ────────────────────────────────────────────────────────────────

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

// ── Session state (persisted by Firebase Auth across restarts) ────────────────

final authStateChangesProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Derived auth status used by routing and splash screen.
final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return authState.when(
    loading: () => AuthStatus.loading,
    error: (_, _) => AuthStatus.unauthenticated,
    data: (user) => user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
  );
});

/// Convenience accessor for the signed-in user.
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateChangesProvider).value;
});

// ── Auth form actions (login, register, password reset) ───────────────────────

class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.signInWithEmail(email: email, password: password);
      state = const AuthFormState();
      return true;
    } on AuthFailure catch (e) {
      state = AuthFormState(errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      state = const AuthFormState();
      return true;
    } on AuthFailure catch (e) {
      state = AuthFormState(errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true, clearPasswordReset: true);

    try {
      await _repository.sendPasswordResetEmail(email: email);
      state = const AuthFormState(isPasswordResetSent: true);
      return true;
    } on AuthFailure catch (e) {
      state = AuthFormState(errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthFormState(
        errorMessage: 'Could not send reset email. Please try again.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.signOut();
    } on AuthFailure catch (e) {
      state = AuthFormState(errorMessage: e.message);
      return;
    }
    state = const AuthFormState();
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthFormState>(AuthController.new);
