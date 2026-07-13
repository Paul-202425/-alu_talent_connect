import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:alu_talent_connect/app.dart';
import 'package:alu_talent_connect/core/constants/app_constants.dart';
import 'package:alu_talent_connect/core/router/app_router.dart';
import 'package:alu_talent_connect/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Login screen displays sign in form', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(
            GoRouter(
              initialLocation: AppRouter.login,
              routes: [
                GoRoute(
                  path: AppRouter.login,
                  builder: (context, state) => const LoginScreen(),
                ),
              ],
            ),
          ),
        ],
        child: const AluTalentConnectApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text(AppConstants.appName), findsNothing);
  });
}
