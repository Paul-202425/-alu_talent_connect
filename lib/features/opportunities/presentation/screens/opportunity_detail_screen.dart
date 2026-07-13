import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../applications/domain/entities/application.dart';
import '../../../applications/presentation/providers/application_providers.dart';
import '../../../applications/presentation/widgets/application_status_badge.dart';
import '../../../applications/presentation/widgets/application_success_dialog.dart';
import '../../../applications/presentation/widgets/apply_bottom_sheet.dart';
import '../../../profiles/domain/entities/user_profile.dart';
import '../../../profiles/presentation/providers/profile_providers.dart';
import '../../domain/entities/opportunity.dart';
import '../providers/opportunity_providers.dart';
import '../widgets/skill_chip.dart';

/// Pops back to the previous screen, or falls back to the home feed when
/// there is nothing to pop (e.g. this route was reached directly via a
/// shared link, deep link, or a web refresh on this URL).
void _goBackOrHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRouter.home);
  }
}

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
  });

  final String opportunityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityAsync = ref.watch(opportunityDetailProvider(opportunityId));
    final profile = ref.watch(currentUserProfileProvider).value;
    final existingApplication = ref.watch(opportunityApplicationProvider(opportunityId));

    return Scaffold(
      appBar: opportunityAsync.maybeWhen(
        data: (opportunity) => opportunity == null
            ? AppBar(
                leading: BackButton(onPressed: () => _goBackOrHome(context)),
              )
            : null,
        orElse: () => AppBar(
          leading: BackButton(onPressed: () => _goBackOrHome(context)),
        ),
      ),
      body: opportunityAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, _) => ErrorState(
          message: 'Could not load this opportunity.',
          onRetry: () => ref.invalidate(opportunityDetailProvider(opportunityId)),
        ),
        data: (Opportunity? opportunity) {
          if (opportunity == null) {
            return ErrorState(
              message: 'This opportunity no longer exists.',
              onRetry: () => _goBackOrHome(context),
            );
          }

          return _DetailContent(
            opportunity: opportunity,
            userSkills: profile?.skills ?? [],
            existingApplication: existingApplication.value,
          );
        },
      ),
      bottomNavigationBar: opportunityAsync.maybeWhen(
        data: (opportunity) {
          if (opportunity == null) return null;
          return _ApplyBar(
            opportunity: opportunity,
            profile: profile,
            application: existingApplication.value,
          );
        },
        orElse: () => null,
      ),
    );
  }
}

class _ApplyBar extends ConsumerWidget {
  const _ApplyBar({
    required this.opportunity,
    required this.profile,
    required this.application,
  });

  final Opportunity opportunity;
  final UserProfile? profile;
  final Application? application;

  Future<void> _handleApply(BuildContext context, WidgetRef ref) async {
    final userProfile = profile;
    if (userProfile == null) return;

    ref.read(applicationControllerProvider.notifier).clearState();

    final submitted = await ApplyBottomSheet.show(
      context,
      opportunity: opportunity,
      applicantName: userProfile.fullName,
      applicantEmail: userProfile.email,
    );

    if (submitted == true && context.mounted) {
      await ApplicationSuccessDialog.show(
        context,
        opportunityTitle: opportunity.title,
        startupName: opportunity.startupName,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile == null) return const SizedBox.shrink();

    if (!profile!.isStudent) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Only students can apply to opportunities.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    if (application != null) {
      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You applied to this role',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    ApplicationStatusBadge(status: application!.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final formState = ref.watch(applicationControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: formState.isLoading ? null : () => _handleApply(context, ref),
          icon: formState.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded),
          label: Text(formState.isLoading ? 'Submitting...' : 'Apply Now'),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.opportunity,
    required this.userSkills,
    this.existingApplication,
  });

  final Opportunity opportunity;
  final List<String> userSkills;
  final Application? existingApplication;

  @override
  Widget build(BuildContext context) {
    final userSkillSet = userSkills.map((s) => s.toLowerCase()).toSet();
    final matchScore = opportunity.skillMatchScore(userSkills);
    final dateFormat = DateFormat('MMM d, yyyy');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Back',
            onPressed: () => _goBackOrHome(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(56, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        opportunity.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opportunity.startupName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (existingApplication != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Application status: ${existingApplication!.status.label}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      ApplicationStatusBadge(status: existingApplication!.status),
                    ],
                  ),
                ),
              if (matchScore > 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.success),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$matchScore of your skills match this role',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              _InfoRow(
                icon: Icons.category_outlined,
                label: 'Type',
                value: opportunity.type.label,
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: opportunity.location.label,
              ),
              _InfoRow(
                icon: Icons.schedule_rounded,
                label: 'Duration',
                value: opportunity.duration,
              ),
              _InfoRow(
                icon: Icons.people_outline_rounded,
                label: 'Applications',
                value: '${opportunity.applicationCount} students applied',
              ),
              if (opportunity.createdAt != null)
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Posted',
                  value: dateFormat.format(opportunity.createdAt!),
                ),
              const SizedBox(height: 24),
              Text(
                'About this role',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                opportunity.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
              if (opportunity.requiredSkills.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Required skills',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.requiredSkills.map((skill) {
                    return SkillChip(
                      label: skill,
                      isHighlighted: userSkillSet.contains(skill.toLowerCase()),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
