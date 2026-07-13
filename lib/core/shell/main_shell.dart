import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/applications/presentation/screens/applications_dashboard_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_feed_screen.dart';
import '../../features/profiles/domain/entities/user_profile.dart';
import '../../features/profiles/presentation/providers/profile_providers.dart';
import '../../features/profiles/presentation/widgets/profile_skeleton.dart';

/// Main authenticated shell with bottom navigation.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const OpportunityFeedScreen(),
          ApplicationsDashboardScreen(
            onBrowseOpportunities: () => setState(() => _currentIndex = 0),
          ),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline_rounded),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final formState = ref.watch(authControllerProvider);

    return Scaffold(
      body: profileAsync.when(
        loading: () => const ProfileSkeleton(),
        error: (_, _) => ErrorState(
          message: 'Could not load your profile.',
          onRetry: () => ref.invalidate(currentUserProfileProvider),
        ),
        data: (UserProfile? profile) {
          if (profile == null) {
            final isSignedIn = ref.watch(currentUserProvider) != null;
            if (!isSignedIn) {
              // Signed out: the router is redirecting to /login, nothing to show here.
              return const SizedBox.shrink();
            }
            return const Center(child: Text('Profile not found.'));
          }

          final roleLabel =
              profile.role == UserRole.student ? 'Student' : 'Startup Founder';
          final roleIcon = profile.isStudent
              ? Icons.person_search_rounded
              : Icons.rocket_launch_rounded;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: const Text('Profile'),
                actions: [
                  IconButton(
                    tooltip: 'Sign out',
                    onPressed: formState.isLoading
                        ? null
                        : () async {
                            await ref.read(authControllerProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go(AppRouter.login);
                            }
                          },
                    icon: formState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          gradient: AppDecorations.brandGradient,
                          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                profile.fullName.isNotEmpty
                                    ? profile.fullName[0].toUpperCase()
                                    : '?',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              profile.fullName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(roleIcon, size: 16, color: AppColors.textPrimary),
                                  const SizedBox(width: 6),
                                  Text(
                                    roleLabel,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (profile.isStartupFounder) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _FounderStartupSection(profile: profile),
                      ],
                      if (profile.skills.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _ProfileSection(
                          title: 'Skills',
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: profile.skills
                                .map(
                                  (skill) => Chip(
                                    label: Text(skill),
                                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _ProfileSection(
                          title: 'Bio',
                          child: Text(
                            profile.bio!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FounderStartupSection extends ConsumerWidget {
  const _FounderStartupSection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (profile.startupId == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: AppDecorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set up your startup',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your startup profile so you can post opportunities.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () => context.push(AppRouter.createStartup),
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Create startup'),
            ),
          ],
        ),
      );
    }

    final startupAsync = ref.watch(currentUserStartupProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            startupAsync.value?.name ?? 'Your startup',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRouter.myOpportunities),
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text('My opportunities'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push(AppRouter.createOpportunity),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Post role'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
