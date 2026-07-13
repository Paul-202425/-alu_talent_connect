import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/profile_providers.dart';

class CreateStartupScreen extends ConsumerStatefulWidget {
  const CreateStartupScreen({super.key});

  @override
  ConsumerState<CreateStartupScreen> createState() => _CreateStartupScreenState();
}

class _CreateStartupScreenState extends ConsumerState<CreateStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _industryController = TextEditingController();
  final _teamSizeController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    _teamSizeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(startupControllerProvider.notifier).createStartup(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          industry: _industryController.text.trim(),
          teamSize: int.tryParse(_teamSizeController.text.trim()),
          website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(startupControllerProvider);
    final isLoading = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Set up your startup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell students about your startup',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This profile is required before you can post opportunities.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                if (formState.errorMessage != null) ...[
                  ErrorBanner(
                    message: formState.errorMessage!,
                    onDismiss: () {},
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _nameController,
                  label: 'Startup name',
                  hint: 'HarvestLink',
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.business_outlined,
                  validator: (v) => Validators.requiredField(v, fieldName: 'Startup name'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _industryController,
                  label: 'Industry',
                  hint: 'Fintech, AgriTech, EdTech...',
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.category_outlined,
                  validator: (v) => Validators.requiredField(v, fieldName: 'Industry'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'What does your startup do?',
                  enabled: !isLoading,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  validator: (v) => Validators.requiredField(v, fieldName: 'Description'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _teamSizeController,
                  label: 'Team size (optional)',
                  hint: 'e.g. 8',
                  enabled: !isLoading,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.groups_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _websiteController,
                  label: 'Website (optional)',
                  hint: 'https://...',
                  enabled: !isLoading,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.link,
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Create startup',
                  isLoading: isLoading,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
