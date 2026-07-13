import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_providers.dart';
import '../widgets/auth_form_overlay.dart';
import '../widgets/auth_scaffold.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    ref.read(authControllerProvider.notifier).clearError();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(AppRouter.home);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();

    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset password'),
          content: Form(
            key: formKey,
            child: AppTextField(
              controller: emailController,
              label: 'Email',
              hint: 'you@alu.edu',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Send link'),
            ),
          ],
        );
      },
    );

    if (sent == true && mounted) {
      final success = await ref.read(authControllerProvider.notifier).sendPasswordReset(
            email: emailController.text,
          );
      emailController.dispose();

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent. Check your inbox.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      emailController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authControllerProvider);
    final isLoading = formState.isLoading;

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to discover internships at ALU startups.',
      bottom: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).clearError();
                    context.go(AppRouter.register);
                  },
            child: const Text('Sign up'),
          ),
        ],
      ),
      child: AuthFormOverlay(
        isLoading: isLoading,
        message: 'Signing you in...',
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (formState.errorMessage != null) ...[
                ErrorBanner(
                  message: formState.errorMessage!,
                  onDismiss: () => ref.read(authControllerProvider.notifier).clearError(),
                ),
                const SizedBox(height: 16),
              ],
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'you@alu.edu',
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.email_outlined,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                enabled: !isLoading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline,
                onFieldSubmitted: (_) => _handleSignIn(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: isLoading
                      ? null
                      : () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: Validators.password,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading ? null : _showForgotPasswordDialog,
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Sign In',
                isLoading: isLoading,
                onPressed: _handleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
