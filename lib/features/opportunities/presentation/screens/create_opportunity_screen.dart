import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/enums/opportunity_type.dart';
import '../../domain/enums/work_location.dart';
import '../providers/opportunity_providers.dart';

class CreateOpportunityScreen extends ConsumerStatefulWidget {
  const CreateOpportunityScreen({super.key});

  @override
  ConsumerState<CreateOpportunityScreen> createState() => _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState extends ConsumerState<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _skillsController = TextEditingController();
  OpportunityType _type = OpportunityType.internship;
  WorkLocation _location = WorkLocation.hybrid;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final success = await ref.read(opportunityControllerProvider.notifier).createOpportunity(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          location: _location,
          type: _type,
          requiredSkills: skills,
          duration: _durationController.text.trim(),
        );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(opportunityControllerProvider);
    final isLoading = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Post an opportunity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (formState.errorMessage != null) ...[
                  ErrorBanner(
                    message: formState.errorMessage!,
                    onDismiss: () {},
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Frontend Engineering Intern',
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.work_outline_rounded,
                  validator: (v) => Validators.requiredField(v, fieldName: 'Title'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'What will the student work on?',
                  enabled: !isLoading,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  validator: (v) => Validators.requiredField(v, fieldName: 'Description'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<OpportunityType>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: OpportunityType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: isLoading ? null : (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<WorkLocation>(
                  initialValue: _location,
                  decoration: const InputDecoration(labelText: 'Location'),
                  items: WorkLocation.values
                      .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
                      .toList(),
                  onChanged: isLoading ? null : (v) => setState(() => _location = v!),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _durationController,
                  label: 'Duration',
                  hint: 'e.g. 3 months',
                  enabled: !isLoading,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.schedule_rounded,
                  validator: (v) => Validators.requiredField(v, fieldName: 'Duration'),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _skillsController,
                  label: 'Required skills',
                  hint: 'Flutter, Dart, Firebase (comma-separated)',
                  enabled: !isLoading,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.auto_awesome_outlined,
                  onFieldSubmitted: (_) => _handleSubmit(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Post opportunity',
                  isLoading: isLoading,
                  icon: Icons.send_rounded,
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
