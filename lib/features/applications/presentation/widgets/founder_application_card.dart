import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/application.dart';
import '../../domain/enums/application_status.dart';
import '../providers/application_providers.dart';
import 'application_status_badge.dart';

class FounderApplicationCard extends ConsumerWidget {
  const FounderApplicationCard({super.key, required this.application});

  final Application application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = ref.watch(applicationReviewControllerProvider).contains(application.id);
    final dateLabel = application.createdAt != null
        ? DateFormat('MMM d, yyyy').format(application.createdAt!)
        : 'Recently';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.applicantEmail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              ApplicationStatusBadge(status: application.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Applied for ${application.opportunityTitle} · $dateLabel',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (application.coverLetter != null && application.coverLetter!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              application.coverLetter!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
          if (!application.status.isTerminal) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating
                        ? null
                        : () => ref.read(applicationReviewControllerProvider.notifier).updateStatus(
                              applicationId: application.id,
                              status: ApplicationStatus.rejected,
                            ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: isUpdating
                        ? null
                        : () => ref.read(applicationReviewControllerProvider.notifier).updateStatus(
                              applicationId: application.id,
                              status: ApplicationStatus.accepted,
                            ),
                    child: isUpdating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
