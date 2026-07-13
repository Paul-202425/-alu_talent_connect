import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/providers/firebase_providers.dart';
import '../../../profiles/presentation/providers/profile_providers.dart';
import '../../data/datasources/opportunity_remote_datasource.dart';
import '../../data/repositories/opportunity_repository_impl.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/enums/opportunity_type.dart';
import '../../domain/enums/work_location.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../state/opportunity_form_state.dart';

final opportunityRemoteDataSourceProvider = Provider<OpportunityRemoteDataSource>((ref) {
  return OpportunityRemoteDataSource(ref.watch(firestoreProvider));
});

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepositoryImpl(ref.watch(opportunityRemoteDataSourceProvider));
});

/// Real-time feed of active opportunities from Firestore.
final activeOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchActiveOpportunities();
});

/// Real-time single opportunity — updates live on detail screen.
final opportunityDetailProvider =
    StreamProvider.family<Opportunity?, String>((ref, opportunityId) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunity(opportunityId);
});

/// Opportunities sorted by skill match against the current user's profile.
final recommendedOpportunitiesProvider = Provider<AsyncValue<List<Opportunity>>>((ref) {
  final opportunitiesAsync = ref.watch(activeOpportunitiesProvider);
  final profile = ref.watch(currentUserProfileProvider).value;

  return opportunitiesAsync.whenData((opportunities) {
    if (profile == null || profile.skills.isEmpty) return opportunities;

    final sorted = [...opportunities]
      ..sort((a, b) {
        final scoreA = a.skillMatchScore(profile.skills);
        final scoreB = b.skillMatchScore(profile.skills);
        if (scoreA != scoreB) return scoreB.compareTo(scoreA);
        return (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
      });

    return sorted;
  });
});

/// Real-time list of the current founder's own postings (active + inactive).
final myOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final profile = ref.watch(currentUserProfileProvider).value;

  if (profile?.startupId == null) {
    return Stream.value([]);
  }

  return ref.watch(opportunityRepositoryProvider).watchOpportunitiesByStartup(profile!.startupId!);
});

class OpportunityController extends Notifier<OpportunityFormState> {
  @override
  OpportunityFormState build() => const OpportunityFormState();

  Future<bool> createOpportunity({
    required String title,
    required String description,
    required WorkLocation location,
    required OpportunityType type,
    required List<String> requiredSkills,
    required String duration,
  }) async {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile?.startupId == null) {
      state = const OpportunityFormState(
        errorMessage: 'You need to set up your startup before posting opportunities.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final startup = await ref.read(startupRepositoryProvider).getStartup(profile!.startupId!);
      await ref.read(opportunityRepositoryProvider).createOpportunity(
            startupId: profile.startupId!,
            startupName: startup?.name ?? profile.fullName,
            title: title,
            description: description,
            location: location,
            type: type,
            requiredSkills: requiredSkills,
            duration: duration,
          );
      state = const OpportunityFormState(isSuccess: true);
      return true;
    } on ServerFailure catch (e) {
      state = OpportunityFormState(errorMessage: e.message);
      return false;
    } catch (_) {
      state = const OpportunityFormState(
        errorMessage: 'Could not post this opportunity. Please try again.',
      );
      return false;
    }
  }

  Future<void> setActive({required String opportunityId, required bool isActive}) async {
    await ref
        .read(opportunityRepositoryProvider)
        .setOpportunityActive(opportunityId: opportunityId, isActive: isActive);
  }
}

final opportunityControllerProvider =
    NotifierProvider<OpportunityController, OpportunityFormState>(OpportunityController.new);
