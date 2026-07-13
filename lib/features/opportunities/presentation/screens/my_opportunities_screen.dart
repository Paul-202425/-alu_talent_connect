import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/opportunity.dart';
import '../providers/opportunity_providers.dart';

class MyOpportunitiesScreen extends ConsumerWidget {
  const MyOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(myOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My opportunities'),
        actions: [
          IconButton(
            tooltip: 'Post an opportunity',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(AppRouter.createOpportunity),
          ),
        ],
      ),
      body: opportunitiesAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (_, _) => ErrorState(
          message: 'Could not load your opportunities.',
          onRetry: () => ref.invalidate(myOpportunitiesProvider),
        ),
        data: (opportunities) {
          if (opportunities.isEmpty) {
            return EmptyState(
              icon: Icons.work_outline_rounded,
              title: 'No opportunities yet',
              message: 'Post your first opportunity to start receiving applications.',
              actionLabel: 'Post an opportunity',
              onAction: () => context.push(AppRouter.createOpportunity),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: opportunities.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              return _MyOpportunityCard(opportunity: opportunities[index]);
            },
          );
        },
      ),
    );
  }
}

class _MyOpportunityCard extends ConsumerWidget {
  const _MyOpportunityCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  opportunity.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${opportunity.type.label} · ${opportunity.location.label}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${opportunity.applicationCount} applications',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: opportunity.isActive,
                onChanged: (value) => ref
                    .read(opportunityControllerProvider.notifier)
                    .setActive(opportunityId: opportunity.id, isActive: value),
              ),
              Text(
                opportunity.isActive ? 'Active' : 'Inactive',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
