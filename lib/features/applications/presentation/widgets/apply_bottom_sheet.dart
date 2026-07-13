import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../providers/application_providers.dart';

class ApplyBottomSheet extends ConsumerStatefulWidget {
  const ApplyBottomSheet({
    super.key,
    required this.opportunity,
    required this.applicantName,
    required this.applicantEmail,
  });

  final Opportunity opportunity;
  final String applicantName;
  final String applicantEmail;

  static Future<bool?> show(
    BuildContext context, {
    required Opportunity opportunity,
    required String applicantName,
    required String applicantEmail,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ApplyBottomSheet(
        opportunity: opportunity,
        applicantName: applicantName,
        applicantEmail: applicantEmail,
      ),
    );
  }

  @override
  ConsumerState<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends ConsumerState<ApplyBottomSheet> {
  final _coverLetterController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final application = await ref.read(applicationControllerProvider.notifier).submit(
          opportunity: widget.opportunity,
          applicantName: widget.applicantName,
          applicantEmail: widget.applicantEmail,
          coverLetter: _coverLetterController.text,
        );

    if (application != null && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(applicationControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Apply to ${widget.opportunity.title}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.opportunity.startupName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (formState.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formState.errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 16),
          ],
          AppTextField(
            controller: _coverLetterController,
            label: 'Cover letter (optional)',
            hint: 'Why are you a great fit for this role?',
            enabled: !formState.isLoading,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Submit Application',
            isLoading: formState.isLoading,
            icon: Icons.send_rounded,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
