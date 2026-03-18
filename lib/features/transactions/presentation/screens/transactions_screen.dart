import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/income_tab.dart';
import 'package:savvy/features/transactions/presentation/widgets/expense_tab.dart';
import 'package:savvy/features/transactions/presentation/widgets/savings_tab.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';


// ═══════════════════════════════════════════════════════════════════════
// Ana Ekran
// ═══════════════════════════════════════════════════════════════════════

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedMonth; // null = Tümü

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final allSavingsAsync = ref.watch(allSavingsProvider);

    final isLoading = allIncomesAsync.isLoading ||
        allExpensesAsync.isLoading ||
        allSavingsAsync.isLoading;

    final allIncomes = (allIncomesAsync.value ?? []);
    final allExpenses = (allExpensesAsync.value ?? []);
    final allSavings = (allSavingsAsync.value ?? []);

    // Tüm ayları topla
    final months = <String>{};
    for (final i in allIncomes) {
      months.add(i.date.toYearMonth());
    }
    for (final e in allExpenses) {
      months.add(e.date.toYearMonth());
    }
    for (final s in allSavings) {
      months.add(s.date.toYearMonth());
    }
    months.add(DateTime.now().toYearMonth());
    final sortedMonths = months.toList()..sort((a, b) => b.compareTo(a));

    // Filtreleme
    final incomes = _selectedMonth == null
        ? allIncomes
        : allIncomes.where((i) => i.date.toYearMonth() == _selectedMonth).toList();
    final expenses = _selectedMonth == null
        ? allExpenses
        : allExpenses.where((e) => e.date.toYearMonth() == _selectedMonth).toList();
    final savings = _selectedMonth == null
        ? allSavings
        : allSavings.where((s) => s.date.toYearMonth() == _selectedMonth).toList();

    // Sırala
    incomes.sort((a, b) => b.date.compareTo(a.date));
    expenses.sort((a, b) => b.date.compareTo(a.date));
    savings.sort((a, b) => b.date.compareTo(a.date));

    final totalIncome = incomes.fold(0.0, (sum, i) => sum + i.amount);
    final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalSavings = savings.fold(0.0, (sum, s) => sum + s.amount);

    return SafeArea(
      child: Column(
        children: [
          // Başlık
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
            child: Row(
              children: [
                Text(
                  'İşlemler',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.of(context).textPrimary,
                  ),
                ),
                const Spacer(),
                QuickSummaryChip(net: totalIncome - totalExpense),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Ay seçici
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: sortedMonths.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedMonth == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: MonthChip(
                      label: 'Tümü',
                      isSelected: isSelected,
                      onTap: () => setState(() => _selectedMonth = null),
                    ),
                  );
                }
                final ym = sortedMonths[index - 1];
                final isSelected = _selectedMonth == ym;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: MonthChip(
                    label: MonthLabels.shortName(ym),
                    year: ym.split('-')[0],
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedMonth = ym),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Tab Bar
          Padding(
            padding: AppSpacing.screenH,
            child: ModernTabBar(
              controller: _tabController,
              tabs: [
                TabData('Gelir', totalIncome, AppColors.of(context).income),
                TabData('Gider', totalExpense, AppColors.of(context).expense),
                TabData('Birikim', totalSavings, AppColors.of(context).savings),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Tab içerikleri + FAB
          Expanded(
            child: Stack(
              children: [
                if (isLoading)
                  const Padding(
                    padding: AppSpacing.screenH,
                    child: SavvyShimmer(
                      child: Column(
                        children: [
                          SizedBox(height: AppSpacing.base),
                          ShimmerBox(height: 100),
                          SizedBox(height: AppSpacing.base),
                          ShimmerBox(height: 60),
                          SizedBox(height: AppSpacing.sm),
                          ShimmerBox(height: 60),
                        ],
                      ),
                    ),
                  )
                else
                  TabBarView(
                    controller: _tabController,
                    children: [
                      IncomeTab(
                        incomes: incomes,
                        allIncomes: allIncomes,
                        total: totalIncome,
                      ),
                      ExpenseTab(
                        expenses: expenses,
                        allExpenses: allExpenses,
                        total: totalExpense,
                      ),
                      SavingsTab(
                        savings: savings,
                        allSavings: allSavings,
                        total: totalSavings,
                      ),
                    ],
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
