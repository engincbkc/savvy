import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  TransactionFilters _pendingFilters = const TransactionFilters();
  bool _headerShadow = false;
  bool _showFilters = false;
  Timer? _filterDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    // Varsayılan: mevcut ay seçili
    _selectedMonth = DateTime.now().toYearMonth();
  }

  @override
  void dispose() {
    _filterDebounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onFiltersChanged(TransactionFilters f) {
    _pendingFilters = f;
    _filterDebounce?.cancel();
    if (f.searchQuery != _filters.searchQuery) {
      _filterDebounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _filters = _pendingFilters);
      });
    } else {
      setState(() => _filters = f);
    }
  }

  List<T> _applyFilters<T>(
    List<T> items, {
    required DateTime Function(T) dateOf,
    required double Function(T) amountOf,
    required String Function(T) categoryOf,
    required String? Function(T) noteOf,
  }) {
    var result = items;
    if (_filters.dateFrom != null) {
      result = result.where((i) => !dateOf(i).isBefore(_filters.dateFrom!)).toList();
    }
    if (_filters.dateTo != null) {
      final end = _filters.dateTo!.add(const Duration(days: 1));
      result = result.where((i) => dateOf(i).isBefore(end)).toList();
    }
    if (_filters.amountMin != null) {
      result = result.where((i) => amountOf(i) >= _filters.amountMin!).toList();
    }
    if (_filters.amountMax != null) {
      result = result.where((i) => amountOf(i) <= _filters.amountMax!).toList();
    }
    if (_filters.categories.isNotEmpty) {
      result = result
          .where((i) => _filters.categories.contains(categoryOf(i)))
          .toList();
    }
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
    final c = AppColors.of(context);
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final allSavingsAsync = ref.watch(allSavingsProvider);

    final isLoading = allIncomesAsync.isLoading ||
        allExpensesAsync.isLoading ||
        allSavingsAsync.isLoading;

    final allIncomes = (allIncomesAsync.value ?? []);
    final allExpenses = (allExpensesAsync.value ?? []);
    final allSavings = (allSavingsAsync.value ?? []);

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
    incomes = _applyFilters(incomes, dateOf: (i) => i.date, amountOf: (i) => i.amount, categoryOf: (i) => i.category.label, noteOf: (i) => i.note);
    expenses = _applyFilters(expenses, dateOf: (e) => e.date, amountOf: (e) => e.amount, categoryOf: (e) => e.category.label, noteOf: (e) => e.note);
    savings = _applyFilters(savings, dateOf: (s) => s.date, amountOf: (s) => s.amount, categoryOf: (s) => s.category.label, noteOf: (s) => s.note);

    incomes.sort((a, b) => b.date.compareTo(a.date));
    expenses.sort((a, b) => b.date.compareTo(a.date));
    savings.sort((a, b) => b.date.compareTo(a.date));

    final isTumuMode = _selectedMonth == null;
    final resolveMonth = _selectedMonth != null
        ? int.parse(_selectedMonth!.split('-')[1])
        : DateTime.now().month;
    final totalIncome = incomes.fold(0.0, (sum, i) {
      final month = isTumuMode ? i.date.month : resolveMonth;
      return sum +
          FinancialCalculator.resolveNetForMonth(
            amount: i.amount, isGross: i.isGross, month: month);
    });
    final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalSavings = savings.fold(0.0, (sum, s) => sum + s.amount);

    return SafeArea(
      child: Column(
        children: [
          // ── Header ──
          AnimatedContainer(
            duration: AppDuration.fast,
            curve: AppCurve.standard,
            decoration: BoxDecoration(
              boxShadow: _headerShadow ? AppShadow.sm : AppShadow.none,
            ),
            child: Column(
              children: [
                // Başlık satırı: sadece "İşlemler" + filtre ikonu
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                  child: Row(
                    children: [
                      Text(
                        'İşlemler',
                        style: AppTypography.headlineMedium.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      // Filtre toggle
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showFilters = !_showFilters);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _showFilters || _filters.isActive
                                ? c.brandPrimary.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: AppRadius.chip,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 20,
                                color: _filters.isActive
                                    ? c.brandPrimary
                                    : c.textSecondary,
                              ),
                              if (_filters.isActive)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: c.brandPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      // Periyodik yönetim
                      GestureDetector(
                        onTap: () => context.push('/transactions/recurring'),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.chip,
                          ),
                          child: Icon(
                            AppIcons.recurring,
                            size: 20,
                            color: c.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Filtreler — sadece açıksa göster
                AnimatedCrossFade(
                  firstChild: const SizedBox(height: AppSpacing.sm),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                    child: FilterBar(
                      filters: _filters,
                      activeTabIndex: _tabController.index,
                      onChanged: _onFiltersChanged,
                    ),
                  ),
                  crossFadeState: _showFilters
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Tab Bar + Ekle butonu
                Padding(
                  padding: AppSpacing.screenH,
                  child: Row(
                    children: [
                      Expanded(
                        child: ModernTabBar(
                          controller: _tabController,
                          tabs: [
                            TabData('Gelir', totalIncome, c.income),
                            TabData('Gider', totalExpense, c.expense),
                            TabData('Birikim', totalSavings, c.savings),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _AddButton(
                        tabIndex: _tabController.index,
                        onTap: () => _openAddSheet(context),
                      ),
                    ],
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
                          isTumuMode: isTumuMode,
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

// ═══════════════════════════════════════════════════════════════════════
// Compact Add Button (sits next to tab bar)
// ═══════════════════════════════════════════════════════════════════════

class _AddButton extends StatelessWidget {
  final int tabIndex;
  final VoidCallback onTap;

  const _AddButton({required this.tabIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = switch (tabIndex) {
      0 => AppColors.of(context).income,
      1 => AppColors.of(context).expense,
      _ => AppColors.of(context).savings,
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.card,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}
