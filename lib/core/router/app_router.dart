import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/enums/auth_status.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/opportunities/presentation/screens/create_opportunity_screen.dart';
import '../../features/opportunities/presentation/screens/my_opportunities_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import '../../features/profiles/presentation/screens/create_startup_screen.dart';
import '../shell/main_shell.dart';
import 'router_refresh_notifier.dart';

/// Application routing with auth-aware redirects.
abstract final class AppRouter {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const opportunityDetail = '/opportunities/:id';
  static const createStartup = '/startup/create';
  static const createOpportunity = '/opportunities/create';
  static const myOpportunities = '/startup/opportunities';

  static String opportunityDetailPath(String id) => '/opportunities/$id';

  static const _authRoutes = {login, register};
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: AppRouter.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authStatus = ref.read(authStatusProvider);
      final location = state.matchedLocation;

      if (authStatus == AuthStatus.loading) {
        return location == AppRouter.splash ? null : AppRouter.splash;
      }

      final isLoggedIn = authStatus == AuthStatus.authenticated;
      final isAuthRoute = AppRouter._authRoutes.contains(location);
      final isSplash = location == AppRouter.splash;

      if (!isLoggedIn) {
        if (isAuthRoute) return null;
        if (isSplash) return AppRouter.login;
        return AppRouter.login;
      }

      if (isLoggedIn && (isAuthRoute || isSplash)) {
        return AppRouter.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRouter.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRouter.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRouter.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRouter.home,
        name: 'home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: AppRouter.createStartup,
        name: 'createStartup',
        builder: (context, state) => const CreateStartupScreen(),
      ),
      GoRoute(
        path: AppRouter.createOpportunity,
        name: 'createOpportunity',
        builder: (context, state) => const CreateOpportunityScreen(),
      ),
      GoRoute(
        path: AppRouter.myOpportunities,
        name: 'myOpportunities',
        builder: (context, state) => const MyOpportunitiesScreen(),
      ),
      GoRoute(
        path: AppRouter.opportunityDetail,
        name: 'opportunityDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OpportunityDetailScreen(opportunityId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
