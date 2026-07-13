import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../../profiles/presentation/providers/profile_providers.dart';
import '../../data/datasources/application_remote_datasource.dart';
import '../../data/repositories/application_repository_impl.dart';
import '../../domain/entities/application.dart';
import '../../domain/enums/application_status.dart';
import '../../domain/repositories/application_repository.dart';
import '../state/application_form_state.dart';

final applicationRemoteDataSourceProvider = Provider<ApplicationRemoteDataSource>((ref) {
  return ApplicationRemoteDataSource(ref.watch(firestoreProvider));
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepositoryImpl(ref.watch(applicationRemoteDataSourceProvider));
});

/// Real-time list of the current student's applications.
final studentApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return ref.watch(applicationRepositoryProvider).watchStudentApplications(user.id);
});

/// Real-time application status for a specific opportunity.
final opportunityApplicationProvider =
    StreamProvider.family<Application?, String>((ref, opportunityId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return ref.watch(applicationRepositoryProvider).watchApplicationForOpportunity(
        opportunityId: opportunityId,
        applicantId: user.id,
      );
});

/// Real-time list of applications submitted to the current founder's startup.
final startupApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;

  if (profile?.startupId == null) {
    return Stream.value([]);
  }

  return ref.watch(applicationRepositoryProvider).watchStartupApplications(profile!.startupId!);
});

/// Founder-side status updates (review / accept / reject).
class ApplicationReviewController extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  bool isUpdating(String applicationId) => state.contains(applicationId);

  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    state = {...state, applicationId};
    try {
      await ref.read(applicationRepositoryProvider).updateStatus(
            applicationId: applicationId,
            status: status,
          );
    } finally {
      state = {...state}..remove(applicationId);
    }
  }
}

final applicationReviewControllerProvider =
    NotifierProvider<ApplicationReviewController, Set<String>>(ApplicationReviewController.new);

class ApplicationController extends Notifier<ApplicationFormState> {
  @override
  ApplicationFormState build() => const ApplicationFormState();

  ApplicationRepository get _repository => ref.read(applicationRepositoryProvider);

  Future<Application?> submit({
    required Opportunity opportunity,
    required String applicantName,
    required String applicantEmail,
    String? coverLetter,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = const ApplicationFormState(errorMessage: 'You must be signed in to apply.');
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);

    try {
      final application = await _repository.submitApplication(
        opportunityId: opportunity.id,
        applicantId: user.id,
        applicantName: applicantName,
        applicantEmail: applicantEmail,
        coverLetter: coverLetter,
        opportunity: opportunity,
      );

      state = const ApplicationFormState(isSuccess: true);
      return application;
    } on AuthFailure catch (e) {
      state = ApplicationFormState(errorMessage: e.message);
      return null;
    } on ServerFailure catch (e) {
      state = ApplicationFormState(errorMessage: e.message);
      return null;
    } catch (_) {
      state = const ApplicationFormState(
        errorMessage: 'Could not submit application. Please try again.',
      );
      return null;
    }
  }

  void clearState() {
    state = const ApplicationFormState();
  }
}

final applicationControllerProvider =
    NotifierProvider<ApplicationController, ApplicationFormState>(ApplicationController.new);
