import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_box.dart';

class ApplicationsDashboardSkeleton extends StatelessWidget {
  const ApplicationsDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(child: ShimmerBox(width: double.infinity, height: 64, borderRadius: 12)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(width: double.infinity, height: 64, borderRadius: 12)),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(width: double.infinity, height: 64, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: ShimmerBox(width: double.infinity, height: 100, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }
}
