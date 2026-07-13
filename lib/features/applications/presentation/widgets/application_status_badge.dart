import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/enums/application_status.dart';

class ApplicationStatusBadge extends StatelessWidget {
  const ApplicationStatusBadge({
    super.key,
    required this.status,
  });

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      ApplicationStatus.pending => (AppColors.warning, AppColors.warning.withValues(alpha: 0.15)),
      ApplicationStatus.reviewed => (AppColors.primary, AppColors.primary.withValues(alpha: 0.12)),
      ApplicationStatus.accepted => (AppColors.success, AppColors.success.withValues(alpha: 0.15)),
      ApplicationStatus.rejected => (AppColors.error, AppColors.error.withValues(alpha: 0.12)),
      ApplicationStatus.withdrawn => (AppColors.textSecondary, AppColors.surfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
