import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/navigation/app_shell.dart';
import 'package:savvy/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:savvy/features/auth/presentation/screens/login_screen.dart';
import 'package:savvy/features/auth/presentation/screens/register_screen.dart';
import 'package:savvy/features/onboarding/presentation/screens/onboarding_gate.dart';
import 'package:savvy/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:savvy/features/transactions/presentation/screens/recurring_management_screen.dart';
import 'package:savvy/features/simulation/presentation/screens/simulation_list_screen.dart';
import 'package:savvy/features/simulation/presentation/screens/simulation_template_screen.dart';
import 'package:savvy/features/simulation/presentation/screens/simulation_editor_screen.dart';
import 'package:savvy/features/simulation/presentation/screens/simulation_cashflow_screen.dart';
import 'package:savvy/features/simulation/presentation/screens/simulation_compare_screen.dart';
import 'package:savvy/features/dashboard/presentation/screens/month_detail_screen.dart';
import 'package:savvy/features/dashboard/presentation/screens/cash_flow_forecast_screen.dart';
import 'package:savvy/features/dashboard/presentation/screens/month_compare_screen.dart';
import 'package:savvy/features/debt/presentation/screens/debt_dashboard_screen.dart';
import 'package:savvy/features/budget/presentation/screens/budget_overview_screen.dart';
import 'package:savvy/features/settings/presentation/settings_screen.dart';
import 'package:savvy/features/settings/presentation/screens/tax_report_screen.dart';
import 'package:savvy/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:savvy/features/ai_advisor/presentation/screens/ai_advisor_screen.dart';
import 'package:savvy/features/import/presentation/screens/csv_import_screen.dart';
import 'package:savvy/features/family/presentation/screens/family_overview_screen.dart';

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
            child: OnboardingGate(),
          ),
          routes: [
            GoRoute(
              path: 'month/:yearMonth',
              builder: (context, state) => MonthDetailScreen(
                yearMonth: state.pathParameters['yearMonth']!,
              ),
            ),
            GoRoute(
              path: 'forecast',
              builder: (context, state) => const CashFlowForecastScreen(),
            ),
            GoRoute(
              path: 'compare',
              builder: (context, state) => MonthCompareScreen(
                initialMonth: state.uri.queryParameters['month'],
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/transactions',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TransactionsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'recurring',
              builder: (context, state) =>
                  const RecurringManagementScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/simulate',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SimulationListScreen(),
          ),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) =>
                  const SimulationTemplateScreen(),
            ),
            GoRoute(
              path: 'compare',
              builder: (context, state) =>
                  const SimulationCompareScreen(),
            ),
            GoRoute(
              path: ':simulationId',
              builder: (context, state) => SimulationEditorScreen(
                simulationId: state.pathParameters['simulationId']!,
              ),
              routes: [
                GoRoute(
                  path: 'cashflow',
                  builder: (context, state) => SimulationCashFlowScreen(
                    simulationId: state.pathParameters['simulationId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/debt',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DebtDashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/budget',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: BudgetOverviewScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'tax-report',
              builder: (context, state) => const TaxReportScreen(),
            ),
            GoRoute(
              path: 'notifications',
              builder: (context, state) =>
                  const NotificationSettingsScreen(),
            ),
            GoRoute(
              path: 'import',
              builder: (context, state) => const CsvImportScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/ai-advisor',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AiAdvisorScreen(),
          ),
        ),
        GoRoute(
          path: '/family',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: FamilyOverviewScreen(),
          ),
        ),
      ],
    ),
  ],
);
