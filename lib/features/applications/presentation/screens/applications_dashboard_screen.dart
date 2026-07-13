import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../profiles/domain/entities/user_profile.dart';
import '../../../profiles/presentation/providers/profile_providers.dart';
import '../../domain/enums/application_status.dart';
import '../providers/application_providers.dart';
import '../widgets/application_card.dart';
import '../widgets/applications_dashboard_skeleton.dart';
import '../widgets/founder_application_card.dart';

class ApplicationsDashboardScreen extends ConsumerWidget {
  const ApplicationsDashboardScreen({
    super.key,
    this.onBrowseOpportunities,
  });

  final VoidCallback? onBrowseOpportunities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final applicationsAsync = ref.watch(studentApplicationsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(studentApplicationsProvider);
          await ref.read(studentApplicationsProvider.future);
        },
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppDecorations.brandGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      profile != null && !profile.isStudent
                          ? 'Applications Received'
                          : 'My Applications',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      profile != null && !profile.isStudent
                          ? 'Review and respond to student applications in real time'
                          : 'Track status updates in real time',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (profile != null && !profile.isStudent)
              _FounderApplicationsSection(profile: profile)
            else
              applicationsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: ApplicationsDashboardSkeleton(),
                ),
                error: (_, _) => SliverFillRemaining(
                  child: ErrorState(
                    message: 'Could not load your applications.',
                    onRetry: () => ref.invalidate(studentApplicationsProvider),
                  ),
                ),
                data: (applications) {
                  if (applications.isEmpty) {
                    return SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'No applications yet',
                        message:
                            'Browse opportunities and apply to track your progress here.',
                        actionLabel: 'Browse opportunities',
                        onAction: onBrowseOpportunities,
                      ),
                    );
                  }

                  final pending = applications
                      .where((a) => a.status == ApplicationStatus.pending)
                      .length;
                  final accepted = applications
                      .where((a) => a.status == ApplicationStatus.accepted)
                      .length;

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      AppSpacing.xl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SectionHeader(
                          title: 'Overview',
                          subtitle: 'Your application pipeline',
                        ),
                        _StatsRow(
                          pending: pending,
                          accepted: accepted,
                          total: applications.length,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const SectionHeader(title: 'All applications'),
                        ...applications.map(
                          (application) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: ApplicationCard(
                              application: application,
                              onTap: () => context.push(
                                AppRouter.opportunityDetailPath(application.opportunityId),
                              ),
                            ),
                          ),
                        ),
                      ]),
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

class _FounderApplicationsSection extends ConsumerWidget {
  const _FounderApplicationsSection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile.startupId == null) {
      return SliverFillRemaining(
        child: EmptyState(
          icon: Icons.business_center_outlined,
          title: 'Set up your startup',
          message: 'Create your startup profile to start posting opportunities.',
          actionLabel: 'Create startup',
          onAction: () => context.push(AppRouter.createStartup),
        ),
      );
    }

    final applicationsAsync = ref.watch(startupApplicationsProvider);

    return applicationsAsync.when(
      loading: () => const SliverFillRemaining(child: ApplicationsDashboardSkeleton()),
      error: (_, _) => SliverFillRemaining(
        child: ErrorState(
          message: 'Could not load applications.',
          onRetry: () => ref.invalidate(startupApplicationsProvider),
        ),
      ),
      data: (applications) {
        if (applications.isEmpty) {
          return const SliverFillRemaining(
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'No applications yet',
              message: 'Applications to your opportunities will show up here.',
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
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SectionHeader(title: 'All applications'),
              ...applications.map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: FounderApplicationCard(application: application),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.pending,
    required this.accepted,
    required this.total,
  });

  final int pending;
  final int accepted;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: 'Total', value: total.toString(), color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(label: 'Pending', value: pending.toString(), color: AppColors.warning),
        const SizedBox(width: AppSpacing.sm),
        _StatChip(label: 'Accepted', value: accepted.toString(), color: AppColors.success),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
