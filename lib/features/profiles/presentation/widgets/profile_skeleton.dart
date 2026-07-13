import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/shimmer_box.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: const [
          ShimmerBox(width: 96, height: 96, borderRadius: 48),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: 180, height: 20, borderRadius: 8),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: 220, height: 14, borderRadius: 8),
          SizedBox(height: AppSpacing.sm),
          ShimmerBox(width: 100, height: 28, borderRadius: 14),
          SizedBox(height: AppSpacing.xl),
          ShimmerBox(width: double.infinity, height: 120, borderRadius: 16),
        ],
      ),
    );
  }
}
