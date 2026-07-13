import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ApplicationSuccessDialog extends StatelessWidget {
  const ApplicationSuccessDialog({
    super.key,
    required this.opportunityTitle,
    required this.startupName,
  });

  final String opportunityTitle;
  final String startupName;

  static Future<void> show(
    BuildContext context, {
    required String opportunityTitle,
    required String startupName,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ApplicationSuccessDialog(
        opportunityTitle: opportunityTitle,
        startupName: startupName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
      ),
      title: const Text('Application submitted!'),
      content: Text(
        'Your application for $opportunityTitle at $startupName is now pending review. '
        'Track its status in the Applications tab.',
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
