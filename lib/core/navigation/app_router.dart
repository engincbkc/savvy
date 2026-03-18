import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/navigation/app_shell.dart';
import 'package:savvy/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:savvy/features/auth/presentation/screens/login_screen.dart';
import 'package:savvy/features/auth/presentation/screens/register_screen.dart';
import 'package:savvy/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:savvy/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:savvy/features/simulation/presentation/screens/simulation_screen.dart';
import 'package:savvy/features/dashboard/presentation/screens/month_detail_screen.dart';
import 'package:savvy/features/settings/presentation/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Listenable that fires when Firebase auth state changes,
/// triggering GoRouter to re-evaluate its redirect.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final _authListenable = _AuthStateListenable();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  refreshListenable: _authListenable,
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password';

    if (!loggedIn && !isAuthRoute) return '/login';
    if (loggedIn && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    // Auth routes (no shell)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Main app routes (with shell)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
          routes: [
            GoRoute(
              path: 'month/:yearMonth',
              builder: (context, state) => MonthDetailScreen(
                yearMonth: state.pathParameters['yearMonth']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/transactions',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TransactionsScreen(),
          ),
        ),
        GoRoute(
          path: '/simulate',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SimulationScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
