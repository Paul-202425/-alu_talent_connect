import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/branded_header.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../profiles/presentation/providers/profile_providers.dart';
import '../providers/opportunity_providers.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/opportunity_feed_skeleton.dart';

class OpportunityFeedScreen extends ConsumerWidget {
  const OpportunityFeedScreen({super.key});

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    if (name == null || name.isEmpty) return '$timeGreeting!';
    final firstName = name.split(' ').first;
    return '$timeGreeting, $firstName';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(recommendedOpportunitiesProvider);
    final profile = ref.watch(currentUserProfileProvider).value;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeOpportunitiesProvider);
          await ref.read(activeOpportunitiesProvider.future);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: BrandedHeader(
                greeting: _greeting(profile?.fullName),
                subtitle: 'Discover internships from ALU student-led startups',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Open roles',
                  subtitle: 'Sorted by skill match when available',
                  trailing: IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => ref.invalidate(activeOpportunitiesProvider),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ),
            ),
            opportunitiesAsync.when(
              loading: () => const SliverFillRemaining(
                child: OpportunityFeedSkeleton(),
              ),
              error: (_, _) => SliverFillRemaining(
                child: ErrorState(
                  message: 'Could not load opportunities. Check your connection.',
                  onRetry: () => ref.invalidate(activeOpportunitiesProvider),
                ),
              ),
              data: (opportunities) {
                if (opportunities.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.work_off_outlined,
                      title: 'No opportunities yet',
                      message:
                          'Startups haven\'t posted any internships yet. Check back soon or add sample data in Firestore.',
                      actionLabel: 'Refresh',
                      onAction: () => ref.invalidate(activeOpportunitiesProvider),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    AppSpacing.xl,
                  ),
                  sliver: SliverList.separated(
                    itemCount: opportunities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final opportunity = opportunities[index];
                      return OpportunityCard(
                        opportunity: opportunity,
                        userSkills: profile?.skills ?? [],
                        onTap: () => context.push(
                          AppRouter.opportunityDetailPath(opportunity.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
