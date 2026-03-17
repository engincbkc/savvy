import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/features/transactions/presentation/screens/add_income_sheet.dart';
import 'package:savvy/features/transactions/presentation/screens/add_expense_sheet.dart';
import 'package:savvy/features/transactions/presentation/screens/add_savings_sheet.dart';
import 'package:savvy/shared/widgets/fab_radial_menu.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/simulate')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: FabRadialMenu(
        onAddIncome: () => _showSheet(context, const AddIncomeSheet()),
        onAddExpense: () => _showSheet(context, const AddExpenseSheet()),
        onAddSavings: () => _showSheet(context, const AddSavingsSheet()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex(context),
        onTap: (index) {
          final routes = [
            '/dashboard',
            '/transactions',
            '/simulate',
            '/settings',
          ];
          context.go(routes[index]);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(AppIcons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.analytics),
            label: 'İşlemler',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.simulate),
            label: 'Simülasyon',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
