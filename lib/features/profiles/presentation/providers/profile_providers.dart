import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/startup_remote_datasource.dart';
import '../../data/datasources/user_profile_remote_datasource.dart';
import '../../data/repositories/startup_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/entities/startup_profile.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/startup_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../state/startup_form_state.dart';

final userProfileRemoteDataSourceProvider = Provider<UserProfileRemoteDataSource>((ref) {
  return UserProfileRemoteDataSource(ref.watch(firestoreProvider));
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl(ref.watch(userProfileRemoteDataSourceProvider));
});

/// Real-time profile for the currently signed-in user.
/// Automatically clears when the session ends.
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authUser = ref.watch(currentUserProvider);

  if (authUser == null) {
    return Stream.value(null);
  }

  return ref.watch(userProfileRepositoryProvider).watchProfile(authUser.id);
});

final startupRemoteDataSourceProvider = Provider<StartupRemoteDataSource>((ref) {
  return StartupRemoteDataSource(ref.watch(firestoreProvider));
});

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepositoryImpl(ref.watch(startupRemoteDataSourceProvider));
});

/// Real-time startup profile owned by the current founder, if any.
final currentUserStartupProvider = StreamProvider<StartupProfile?>((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;

  if (profile?.startupId == null) {
    return Stream.value(null);
  }

  return ref.watch(startupRepositoryProvider).watchStartup(profile!.startupId!);
});

class StartupController extends Notifier<StartupFormState> {
  @override
  StartupFormState build() => const StartupFormState();

  Future<bool> createStartup({
    required String name,
    required String description,
    required String industry,
    int? teamSize,
    String? website,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const StartupFormState(errorMessage: 'You must be signed in.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final startup = await ref.read(startupRepositoryProvider).createStartup(
            founderId: user.id,
            name: name,
            description: description,
            industry: industry,
            teamSize: teamSize,
            website: website,
          );
      await ref
          .read(userProfileRepositoryProvider)
          .linkStartup(userId: user.id, startupId: startup.id);
      state = const StartupFormState(isSuccess: true);
      return true;
    } on ServerFailure catch (e) {
      state = StartupFormState(errorMessage: e.message);
      return false;
    } catch (_) {
      state = const StartupFormState(
        errorMessage: 'Could not create your startup. Please try again.',
      );
      return false;
    }
  }
}

final startupControllerProvider =
    NotifierProvider<StartupController, StartupFormState>(StartupController.new);
