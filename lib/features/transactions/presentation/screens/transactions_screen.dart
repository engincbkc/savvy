import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/add_income_sheet.dart';
import 'package:savvy/features/transactions/presentation/screens/add_expense_sheet.dart';
import 'package:savvy/features/transactions/presentation/screens/add_savings_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/income_tab.dart';
import 'package:savvy/features/transactions/presentation/widgets/expense_tab.dart';
import 'package:savvy/features/transactions/presentation/widgets/savings_tab.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/features/transactions/presentation/widgets/filter_bar.dart';
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
  TransactionFilters _filters = const TransactionFilters();
  bool _headerShadow = false;

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

  // Apply filters to any list of items
  List<T> _applyFilters<T>(
    List<T> items, {
    required DateTime Function(T) dateOf,
    required double Function(T) amountOf,
    required String Function(T) categoryOf,
    required String? Function(T) noteOf,
  }) {
    var result = items;

    // Date range
    if (_filters.dateFrom != null) {
      result = result.where((i) => !dateOf(i).isBefore(_filters.dateFrom!)).toList();
    }
    if (_filters.dateTo != null) {
      final end = _filters.dateTo!.add(const Duration(days: 1));
      result = result.where((i) => dateOf(i).isBefore(end)).toList();
    }
    // Amount range
    if (_filters.amountMin != null) {
      result = result.where((i) => amountOf(i) >= _filters.amountMin!).toList();
    }
    if (_filters.amountMax != null) {
      result = result.where((i) => amountOf(i) <= _filters.amountMax!).toList();
    }
    // Categories
    if (_filters.categories.isNotEmpty) {
      result = result
          .where((i) => _filters.categories.contains(categoryOf(i)))
          .toList();
    }
    // Search
    if (_filters.searchQuery.isNotEmpty) {
      final q = _filters.searchQuery.toLowerCase();
      result = result.where((i) {
        final note = noteOf(i)?.toLowerCase() ?? '';
        final cat = categoryOf(i).toLowerCase();
        return note.contains(q) || cat.contains(q);
      }).toList();
    }

    return result;
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

    // Month filtering
    var incomes = _selectedMonth == null
        ? allIncomes
        : allIncomes.where((i) => i.date.toYearMonth() == _selectedMonth).toList();
    var expenses = _selectedMonth == null
        ? allExpenses
        : allExpenses.where((e) => e.date.toYearMonth() == _selectedMonth).toList();
    var savings = _selectedMonth == null
        ? allSavings
        : allSavings.where((s) => s.date.toYearMonth() == _selectedMonth).toList();

    // Advanced filters
    incomes = _applyFilters(
      incomes,
      dateOf: (i) => i.date,
      amountOf: (i) => i.amount,
      categoryOf: (i) => i.category.label,
      noteOf: (i) => i.note,
    );
    expenses = _applyFilters(
      expenses,
      dateOf: (e) => e.date,
      amountOf: (e) => e.amount,
      categoryOf: (e) => e.category.label,
      noteOf: (e) => e.note,
    );
    savings = _applyFilters(
      savings,
      dateOf: (s) => s.date,
      amountOf: (s) => s.amount,
      categoryOf: (s) => s.category.label,
      noteOf: (s) => s.note,
    );

    // Sırala
    incomes.sort((a, b) => b.date.compareTo(a.date));
    expenses.sort((a, b) => b.date.compareTo(a.date));
    savings.sort((a, b) => b.date.compareTo(a.date));

    // Seçili ayı belirle (brüt→net çözümlemesi için)
    final resolveMonth = _selectedMonth != null
        ? int.parse(_selectedMonth!.split('-')[1])
        : DateTime.now().month;
    final totalIncome = incomes.fold(0.0, (sum, i) {
      return sum +
          FinancialCalculator.resolveNetForMonth(
            amount: i.amount,
            isGross: i.isGross,
            month: resolveMonth,
          );
    });
    final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalSavings = savings.fold(0.0, (sum, s) => sum + s.amount);

    return Stack(
      children: [
        SafeArea(
          child: Column(
        children: [
          // Header area with animated bottom shadow
          AnimatedContainer(
            duration: AppDuration.fast,
            curve: AppCurve.standard,
            decoration: BoxDecoration(
              boxShadow: _headerShadow ? AppShadow.sm : AppShadow.none,
            ),
            child: Column(
              children: [
                // Başlık
                _StaggeredEntry(
                  delay: 0,
                  child: Padding(
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
                ),

                const SizedBox(height: AppSpacing.sm),

                // Ay seçici
                _StaggeredEntry(
                  delay: 80,
                  child: SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: sortedMonths.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isSelected = _selectedMonth == null;
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: AppSpacing.sm),
                            child: MonthChip(
                              label: 'Tümü',
                              isSelected: isSelected,
                              onTap: () =>
                                  setState(() => _selectedMonth = null),
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
                            onTap: () =>
                                setState(() => _selectedMonth = ym),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Filter bar
                _StaggeredEntry(
                  delay: 160,
                  child: Padding(
                    padding: AppSpacing.screenH,
                    child: FilterBar(
                      filters: _filters,
                      activeTabIndex: _tabController.index,
                      onChanged: (f) => setState(() => _filters = f),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Tab Bar
                _StaggeredEntry(
                  delay: 240,
                  child: Padding(
                    padding: AppSpacing.screenH,
                    child: ModernTabBar(
                      controller: _tabController,
                      tabs: [
                        TabData('Gelir', totalIncome,
                            AppColors.of(context).income),
                        TabData('Gider', totalExpense,
                            AppColors.of(context).expense),
                        TabData('Birikim', totalSavings,
                            AppColors.of(context).savings),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),
              ],
            ),
          ),

          // Tab içerikleri
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                final shouldShow = notification.metrics.pixels > 0;
                if (shouldShow != _headerShadow) {
                  setState(() => _headerShadow = shouldShow);
                }
                return false;
              },
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
                          displayMonth: resolveMonth,
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
          ),
        ],
      ),
        ),
        // FAB
        Positioned(
          right: AppSpacing.lg,
          bottom: AppSpacing.lg + 80, // navbar yüksekliği üstü
          child: _AddTransactionFab(
            tabIndex: _tabController.index,
            onTap: () => _openAddSheet(context),
          ),
        ),
      ],
    );
  }

  void _openAddSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(useRootNavigator: true, 
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (sheetCtx, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.of(sheetCtx).surfaceCard,
            borderRadius: AppRadius.bottomSheet,
          ),
          child: switch (_tabController.index) {
            0 => AddIncomeSheet(scrollController: scrollController),
            1 => AddExpenseSheet(scrollController: scrollController),
            _ => AddSavingsSheet(scrollController: scrollController),
          },
        ),
      ),
    );
  }
}

/// Staggered entrance animation for transaction screen sections.
class _StaggeredEntry extends StatelessWidget {
  final int delay;
  final Widget child;

  const _StaggeredEntry({
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: AppCurve.enter,
      builder: (context, value, child) {
        final adjusted =
            ((value * (600 + delay) - delay) / 600).clamp(0.0, 1.0);
        return Opacity(
          opacity: adjusted,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - adjusted)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _AddTransactionFab extends StatelessWidget {
  final int tabIndex;
  final VoidCallback onTap;

  const _AddTransactionFab({required this.tabIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (tabIndex) {
      0 => (AppColors.of(context).income, 'Gelir Ekle', AppIcons.income),
      1 => (AppColors.of(context).expense, 'Gider Ekle', AppIcons.expense),
      _ => (AppColors.of(context).savings, 'Birikim Ekle', AppIcons.savings),
    };

    return FloatingActionButton.extended(
      heroTag: 'txn_add_fab',
      onPressed: onTap,
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
