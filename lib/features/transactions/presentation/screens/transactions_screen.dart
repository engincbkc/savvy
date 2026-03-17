import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/features/savings/domain/models/savings.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

// ─── Ay isimleri ────────────────────────────────────────────────────────
const _aylar = [
  '',
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

String _kisaAy(String yearMonth) {
  final parts = yearMonth.split('-');
  final month = int.parse(parts[1]);
  return _aylar[month].substring(0, 3);
}

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
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _QuickSummaryChip(net: totalIncome - totalExpense),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Ay seçici
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: sortedMonths.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedMonth == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _MonthChip(
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
                  child: _MonthChip(
                    label: _kisaAy(ym),
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
            child: _ModernTabBar(
              controller: _tabController,
              tabs: [
                _TabData('Gelir', totalIncome, AppColors.income),
                _TabData('Gider', totalExpense, AppColors.expense),
                _TabData('Birikim', totalSavings, AppColors.savings),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Tab içerikleri
          Expanded(
            child: isLoading
                ? const Padding(
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
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _IncomeTab(incomes: incomes, total: totalIncome),
                      _ExpenseTab(expenses: expenses, total: totalExpense),
                      _SavingsTab(savings: savings, total: totalSavings),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Ay Seçici Chip ─────────────────────────────────────────────────────

class _MonthChip extends StatelessWidget {
  final String label;
  final String? year;
  final bool isSelected;
  final VoidCallback onTap;

  const _MonthChip({
    required this.label,
    this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : AppColors.surfaceOverlay,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isSelected
                ? AppColors.brandPrimary
                : AppColors.borderDefault.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (year != null)
              Text(
                year!,
                style: TextStyle(
                  fontSize: 8,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Summary ──────────────────────────────────────────────────────

class _QuickSummaryChip extends StatelessWidget {
  final double net;
  const _QuickSummaryChip({required this.net});

  @override
  Widget build(BuildContext context) {
    final isPositive = net >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.incomeSurface : AppColors.expenseSurface,
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: isPositive
              ? AppColors.income.withValues(alpha: 0.3)
              : AppColors.expense.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? AppIcons.income : AppIcons.expense,
            size: 14,
            color: isPositive ? AppColors.income : AppColors.expense,
          ),
          const SizedBox(width: 4),
          Text(
            'Net: ${isPositive ? '+' : ''}${CurrencyFormatter.compact(net)}',
            style: AppTypography.labelSmall.copyWith(
              color: isPositive ? AppColors.incomeStrong : AppColors.expenseStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Modern Tab Bar ─────────────────────────────────────────────────────

class _TabData {
  final String label;
  final double total;
  final Color color;
  _TabData(this.label, this.total, this.color);
}

class _ModernTabBar extends StatelessWidget {
  final TabController controller;
  final List<_TabData> tabs;

  const _ModernTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(3),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.input,
          boxShadow: AppShadow.sm,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        tabs: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final isSelected = controller.index == i;
          return Tab(
            child: AnimatedDefaultTextStyle(
              duration: AppDuration.fast,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? tab.color : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tab.label),
                  if (isSelected && tab.total > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      CurrencyFormatter.compact(tab.total),
                      style: AppTypography.caption.copyWith(
                        color: tab.color.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Gelir Tab
// ═══════════════════════════════════════════════════════════════════════

class _IncomeTab extends ConsumerWidget {
  final List<Income> incomes;
  final double total;

  const _IncomeTab({required this.incomes, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (incomes.isEmpty) {
      return const EmptyState(
        icon: AppIcons.income,
        title: 'Henüz gelir yok',
        subtitle: 'İlk gelirini ekleyerek başlayabilirsin.',
      );
    }

    // Kategori gruplama
    final grouped = <IncomeCategory, List<Income>>{};
    for (final i in incomes) {
      grouped.putIfAbsent(i.category, () => []).add(i);
    }
    final sortedCats = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, i) => s + i.amount);
        final bT = b.value.fold(0.0, (s, i) => s + i.amount);
        return bT.compareTo(aT);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        _SummaryCard(
          title: 'Toplam Gelir',
          total: total,
          color: AppColors.income,
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          icon: AppIcons.income,
          itemCount: incomes.length,
          categoryCount: grouped.length,
        ),
        const SizedBox(height: AppSpacing.lg),

        _SectionHeader(title: 'Kategorilere Göre', count: grouped.length),
        const SizedBox(height: AppSpacing.sm),
        ...sortedCats.map((entry) {
          final catTotal = entry.value.fold(0.0, (s, i) => s + i.amount);
          return _CategoryRow(
            icon: _incomeIcon(entry.key),
            label: entry.key.label,
            amount: catTotal,
            percentage: total > 0 ? catTotal / total : 0.0,
            color: AppColors.income,
            count: entry.value.length,
          );
        }),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: 'Tüm Gelirler', count: incomes.length),
        const SizedBox(height: AppSpacing.sm),
        ...incomes.map((i) => _SwipeableTransactionTile(
              key: ValueKey(i.id),
              id: i.id,
              title: i.category.label,
              subtitle: i.note,
              amount: i.amount,
              date: i.date,
              color: AppColors.income,
              icon: _incomeIcon(i.category),
              prefix: '+',
              isRecurring: i.isRecurring,
              person: i.person,
              onDelete: () => _confirmDelete(context, ref, i.id, 'gelir'),
              onTap: () => _showEditIncome(context, i),
            )),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('$type Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: AppColors.textPrimary)),
        content: Text('Bu ${type}i silmek istediğine emin misin?',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              ref.read(transactionFormProvider.notifier).deleteIncome(id);
            },
            child:
                Text('Sil', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showEditIncome(BuildContext context, Income income) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditIncomeSheet(income: income),
      ),
    );
  }

  static IconData _incomeIcon(IncomeCategory cat) => switch (cat) {
        IncomeCategory.salary => AppIcons.salary,
        IncomeCategory.sideJob => AppIcons.freelance,
        IncomeCategory.freelance => AppIcons.freelance,
        IncomeCategory.transfer => AppIcons.transfer,
        IncomeCategory.debtCollection => AppIcons.loan,
        IncomeCategory.refund => AppIcons.transfer,
        IncomeCategory.rentalIncome => AppIcons.rent,
        IncomeCategory.investment => AppIcons.investment,
        IncomeCategory.other => AppIcons.income,
      };
}

// ═══════════════════════════════════════════════════════════════════════
// Gider Tab
// ═══════════════════════════════════════════════════════════════════════

class _ExpenseTab extends ConsumerWidget {
  final List<Expense> expenses;
  final double total;

  const _ExpenseTab({required this.expenses, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (expenses.isEmpty) {
      return const EmptyState(
        icon: AppIcons.expense,
        title: 'Henüz gider yok',
        subtitle: 'İlk giderini ekleyerek başlayabilirsin.',
      );
    }

    final grouped = <ExpenseCategory, List<Expense>>{};
    for (final e in expenses) {
      grouped.putIfAbsent(e.category, () => []).add(e);
    }
    final sortedCats = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, e) => s + e.amount);
        final bT = b.value.fold(0.0, (s, e) => s + e.amount);
        return bT.compareTo(aT);
      });

    final byType = <ExpenseType, double>{};
    for (final e in expenses) {
      byType[e.expenseType] = (byType[e.expenseType] ?? 0) + e.amount;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        _SummaryCard(
          title: 'Toplam Gider',
          total: total,
          color: AppColors.expense,
          gradient: const [Color(0xFFC81E1E), Color(0xFFEF4444)],
          icon: AppIcons.expense,
          itemCount: expenses.length,
          categoryCount: grouped.length,
        ),
        const SizedBox(height: AppSpacing.base),

        _ExpenseTypeRow(byType: byType, total: total),
        const SizedBox(height: AppSpacing.lg),

        _SectionHeader(title: 'Kategorilere Göre', count: grouped.length),
        const SizedBox(height: AppSpacing.sm),
        ...sortedCats.map((entry) {
          final catTotal = entry.value.fold(0.0, (s, e) => s + e.amount);
          return _CategoryRow(
            icon: _expenseIcon(entry.key),
            label: entry.key.label,
            amount: catTotal,
            percentage: total > 0 ? catTotal / total : 0.0,
            color: AppColors.expense,
            count: entry.value.length,
          );
        }),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: 'Tüm Giderler', count: expenses.length),
        const SizedBox(height: AppSpacing.sm),
        ...expenses.map((e) => _SwipeableTransactionTile(
              key: ValueKey(e.id),
              id: e.id,
              title: e.category.label,
              subtitle: e.note,
              amount: e.amount,
              date: e.date,
              color: AppColors.expense,
              icon: _expenseIcon(e.category),
              prefix: '-',
              isRecurring: e.isRecurring,
              person: e.person,
              onDelete: () => _confirmDelete(context, ref, e.id),
              onTap: () => _showEditExpense(context, e),
            )),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Gider Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: AppColors.textPrimary)),
        content: Text('Bu gideri silmek istediğine emin misin?',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              ref.read(transactionFormProvider.notifier).deleteExpense(id);
            },
            child: Text('Sil', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showEditExpense(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditExpenseSheet(expense: expense),
      ),
    );
  }

  static IconData _expenseIcon(ExpenseCategory cat) => switch (cat) {
        ExpenseCategory.rent => AppIcons.rent,
        ExpenseCategory.market => AppIcons.market,
        ExpenseCategory.transport => AppIcons.transport,
        ExpenseCategory.bills => AppIcons.bills,
        ExpenseCategory.creditCard => AppIcons.loan,
        ExpenseCategory.loanInstallment => AppIcons.loan,
        ExpenseCategory.health => AppIcons.health,
        ExpenseCategory.education => AppIcons.education,
        ExpenseCategory.food => AppIcons.food,
        ExpenseCategory.entertainment => AppIcons.fun,
        ExpenseCategory.clothing => AppIcons.clothing,
        ExpenseCategory.subscription => AppIcons.subscription,
        ExpenseCategory.advertising => AppIcons.ad,
        ExpenseCategory.businessTool => AppIcons.freelance,
        ExpenseCategory.tax => AppIcons.tax,
        ExpenseCategory.other => AppIcons.expense,
      };
}

// ═══════════════════════════════════════════════════════════════════════
// Birikim Tab
// ═══════════════════════════════════════════════════════════════════════

class _SavingsTab extends ConsumerWidget {
  final List<Savings> savings;
  final double total;

  const _SavingsTab({required this.savings, required this.total});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (savings.isEmpty) {
      return const EmptyState(
        icon: AppIcons.savings,
        title: 'Henüz birikim yok',
        subtitle: 'İlk birikimini ekleyerek başlayabilirsin.',
      );
    }

    final grouped = <SavingsCategory, List<Savings>>{};
    for (final s in savings) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }
    final sortedCats = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, i) => s + i.amount);
        final bT = b.value.fold(0.0, (s, i) => s + i.amount);
        return bT.compareTo(aT);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        _SummaryCard(
          title: 'Toplam Birikim',
          total: total,
          color: AppColors.savings,
          gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
          icon: AppIcons.savings,
          itemCount: savings.length,
          categoryCount: grouped.length,
        ),
        const SizedBox(height: AppSpacing.lg),

        _SectionHeader(title: 'Kategorilere Göre', count: grouped.length),
        const SizedBox(height: AppSpacing.sm),
        ...sortedCats.map((entry) {
          final catTotal = entry.value.fold(0.0, (s, i) => s + i.amount);
          return _CategoryRow(
            icon: _savingsIcon(entry.key),
            label: entry.key.label,
            amount: catTotal,
            percentage: total > 0 ? catTotal / total : 0.0,
            color: AppColors.savings,
            count: entry.value.length,
          );
        }),

        const SizedBox(height: AppSpacing.xl),

        _SectionHeader(title: 'Tüm Birikimler', count: savings.length),
        const SizedBox(height: AppSpacing.sm),
        ...savings.map((s) => _SwipeableTransactionTile(
              key: ValueKey(s.id),
              id: s.id,
              title: s.category.label,
              subtitle: s.note,
              amount: s.amount,
              date: s.date,
              color: AppColors.savings,
              icon: _savingsIcon(s.category),
              prefix: '',
              isRecurring: false,
              person: null,
              onDelete: () => _confirmDelete(context, ref, s.id),
              onTap: () => _showEditSavings(context, s),
            )),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Birikim Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: AppColors.textPrimary)),
        content: Text('Bu birikimi silmek istediğine emin misin?',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              ref.read(transactionFormProvider.notifier).deleteSavings(id);
            },
            child: Text('Sil', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  void _showEditSavings(BuildContext context, Savings s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditSavingsSheet(savings: s),
      ),
    );
  }

  static IconData _savingsIcon(SavingsCategory cat) => switch (cat) {
        SavingsCategory.emergency => AppIcons.emergency,
        SavingsCategory.goal => AppIcons.goal,
        SavingsCategory.gold => AppIcons.gold,
        SavingsCategory.forex => AppIcons.transfer,
        SavingsCategory.stock => AppIcons.stock,
        SavingsCategory.fund => AppIcons.investment,
        SavingsCategory.deposit => AppIcons.loan,
        SavingsCategory.retirement => AppIcons.retirement,
        SavingsCategory.other => AppIcons.savings,
      };
}

// ═══════════════════════════════════════════════════════════════════════
// Ortak Widget'lar
// ═══════════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final String title;
  final double total;
  final Color color;
  final List<Color> gradient;
  final IconData icon;
  final int itemCount;
  final int categoryCount;

  const _SummaryCard({
    required this.title,
    required this.total,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.itemCount,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(title,
                  style: AppTypography.titleMedium
                      .copyWith(color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: total),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, _) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericLarge.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _MiniChip(
                label: '$itemCount işlem',
                bgColor: Colors.white.withValues(alpha: 0.15),
                textColor: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: AppSpacing.sm),
              _MiniChip(
                label: '$categoryCount kategori',
                bgColor: Colors.white.withValues(alpha: 0.15),
                textColor: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _MiniChip(
      {required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: AppRadius.pill),
      child: Text(label,
          style: AppTypography.caption
              .copyWith(color: textColor, fontWeight: FontWeight.w500)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: AppColors.surfaceOverlay, borderRadius: AppRadius.pill),
          child: Text('$count',
              style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final double percentage;
  final Color color;
  final int count;

  const _CategoryRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.input,
        border:
            Border.all(color: AppColors.borderDefault.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.textPrimary)),
                    Text('$count işlem',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.formatNoDecimal(amount),
                      style: AppTypography.numericSmall
                          .copyWith(color: color, fontWeight: FontWeight.w700)),
                  Text('%${(percentage * 100).toStringAsFixed(1)}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Swipeable İşlem Kartı ──────────────────────────────────────────────

class _SwipeableTransactionTile extends StatelessWidget {
  final String id;
  final String title;
  final String? subtitle;
  final double amount;
  final DateTime date;
  final Color color;
  final IconData icon;
  final String prefix;
  final bool isRecurring;
  final String? person;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SwipeableTransactionTile({
    super.key,
    required this.id,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.date,
    required this.color,
    required this.icon,
    required this.prefix,
    required this.isRecurring,
    this.person,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    final parts = <String>[dateStr];
    if (person != null && person!.isNotEmpty) parts.add(person!);
    if (subtitle != null && subtitle!.isNotEmpty) parts.add(subtitle!);

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Dialog kendisi siler
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: AppRadius.chip,
        ),
        child: const Icon(AppIcons.delete, color: Colors.white, size: 20),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.chip,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              style: AppTypography.titleSmall
                                  .copyWith(color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (isRecurring) ...[
                          const SizedBox(width: 4),
                          Icon(AppIcons.recurring, size: 12, color: color),
                        ],
                      ],
                    ),
                    Text(parts.join(' · '),
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(
                '$prefix${CurrencyFormatter.formatNoDecimal(amount)}',
                style: AppTypography.numericSmall
                    .copyWith(color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gider Tipi Satırı ──────────────────────────────────────────────────

class _ExpenseTypeRow extends StatelessWidget {
  final Map<ExpenseType, double> byType;
  final double total;

  const _ExpenseTypeRow({required this.byType, required this.total});

  @override
  Widget build(BuildContext context) {
    if (byType.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: byType.entries.map((entry) {
        final pct = total > 0 ? (entry.value / total * 100) : 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.pill,
            border: Border.all(
                color: AppColors.borderDefault.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.key.label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Text('%${pct.toStringAsFixed(0)}',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.expense, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Düzenleme Sheet'leri
// ═══════════════════════════════════════════════════════════════════════

class EditIncomeSheet extends ConsumerStatefulWidget {
  final Income income;
  const EditIncomeSheet({super.key, required this.income});

  @override
  ConsumerState<EditIncomeSheet> createState() => _EditIncomeSheetState();
}

class _EditIncomeSheetState extends ConsumerState<EditIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _personController;
  late IncomeCategory _category;
  late DateTime _date;
  late bool _isRecurring;
  DateTime? _recurringEndDate;

  @override
  void initState() {
    super.initState();
    final i = widget.income;
    _amountController =
        TextEditingController(text: i.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: i.note ?? '');
    _personController = TextEditingController(text: i.person ?? '');
    _category = i.category;
    _date = i.date;
    _isRecurring = i.isRecurring;
    _recurringEndDate = i.recurringEndDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(
        _amountController.text.replaceAll(',', '.').replaceAll(' ', ''));

    final updated = widget.income.copyWith(
      amount: amount,
      category: _category,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateIncome(updated);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)]),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(AppIcons.edit,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gelir Düzenle',
                          style: AppTypography.headlineSmall
                              .copyWith(color: AppColors.textPrimary)),
                      Text('Mevcut gelir kaydını güncelle',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tutar
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.incomeSurfaceDim,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                      color: AppColors.income.withValues(alpha: 0.2)),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                  ],
                  style: AppTypography.numericLarge
                      .copyWith(color: AppColors.incomeStrong),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixText: '₺',
                    suffixStyle: AppTypography.numericMedium
                        .copyWith(color: AppColors.income.withValues(alpha: 0.5)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Tutar giriniz';
                    final parsed = double.tryParse(
                        v.replaceAll(',', '.').replaceAll(' ', ''));
                    if (parsed == null || parsed <= 0) {
                      return 'Geçerli bir tutar giriniz';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Kategori
              Text('Kategori',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: IncomeCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.income
                            : AppColors.surfaceOverlay,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                            color: isSelected
                                ? AppColors.income
                                : AppColors.borderDefault),
                      ),
                      child: Text(cat.label,
                          style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.base),

              // Tarih & Kişi
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 366)),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      child: _EditFieldChip(
                          icon: AppIcons.calendar,
                          label: _formatDate(_date)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _personController,
                      decoration: InputDecoration(
                        hintText: 'Kişi',
                        prefixIcon: const Icon(AppIcons.person, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _noteController,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Not',
                  prefixIcon: Icon(AppIcons.note, size: 18),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Periyodik
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                    color: AppColors.surfaceOverlay,
                    borderRadius: AppRadius.input),
                child: Row(
                  children: [
                    Icon(AppIcons.recurring,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: Text('Periyodik',
                            style: AppTypography.titleSmall
                                .copyWith(color: AppColors.textPrimary))),
                    Switch.adaptive(
                      value: _isRecurring,
                      activeTrackColor: AppColors.income,
                      onChanged: (v) => setState(() {
                        _isRecurring = v;
                        if (!v) _recurringEndDate = null;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.income,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.input),
                    elevation: 0,
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Kaydet',
                          style: AppTypography.labelLarge
                              .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Gider Düzenleme ────────────────────────────────────────────────────

class EditExpenseSheet extends ConsumerStatefulWidget {
  final Expense expense;
  const EditExpenseSheet({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends ConsumerState<EditExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _personController;
  late ExpenseCategory _category;
  late ExpenseType _expenseType;
  late DateTime _date;
  late bool _isRecurring;
  DateTime? _recurringEndDate;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountController =
        TextEditingController(text: e.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: e.note ?? '');
    _personController = TextEditingController(text: e.person ?? '');
    _category = e.category;
    _expenseType = e.expenseType;
    _date = e.date;
    _isRecurring = e.isRecurring;
    _recurringEndDate = e.recurringEndDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _personController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(
        _amountController.text.replaceAll(',', '.').replaceAll(' ', ''));

    final updated = widget.expense.copyWith(
      amount: amount,
      category: _category,
      expenseType: _expenseType,
      person: _personController.text.isEmpty ? null : _personController.text,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: _isRecurring,
      recurringEndDate: _recurringEndDate,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateExpense(updated);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFC81E1E), Color(0xFFEF4444)]),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(AppIcons.edit,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gider Düzenle',
                          style: AppTypography.headlineSmall
                              .copyWith(color: AppColors.textPrimary)),
                      Text('Mevcut gider kaydını güncelle',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tutar
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.expenseSurfaceDim,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                      color: AppColors.expense.withValues(alpha: 0.2)),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                  ],
                  style: AppTypography.numericLarge
                      .copyWith(color: AppColors.expenseStrong),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixText: '₺',
                    suffixStyle: AppTypography.numericMedium.copyWith(
                        color: AppColors.expense.withValues(alpha: 0.5)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Tutar giriniz';
                    final parsed = double.tryParse(
                        v.replaceAll(',', '.').replaceAll(' ', ''));
                    if (parsed == null || parsed <= 0) {
                      return 'Geçerli bir tutar giriniz';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Gider tipi
              Text('Gider Tipi',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: ExpenseType.values.map((type) {
                  final isSelected = _expenseType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _expenseType = type),
                      child: Container(
                        margin: EdgeInsets.only(
                            right: type != ExpenseType.values.last
                                ? AppSpacing.xs
                                : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.expense
                              : AppColors.surfaceOverlay,
                          borderRadius: AppRadius.chip,
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.expense
                                  : AppColors.borderDefault),
                        ),
                        alignment: Alignment.center,
                        child: Text(type.label,
                            style: AppTypography.caption.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.base),

              // Kategori
              Text('Kategori',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: ExpenseCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.expense
                            : AppColors.surfaceOverlay,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                            color: isSelected
                                ? AppColors.expense
                                : AppColors.borderDefault),
                      ),
                      child: Text(cat.label,
                          style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.base),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 366)),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                      child: _EditFieldChip(
                          icon: AppIcons.calendar,
                          label: _formatDate(_date)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _personController,
                      decoration: InputDecoration(
                        hintText: 'Kişi',
                        prefixIcon: const Icon(AppIcons.person, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.md),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _noteController,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Not',
                  prefixIcon: Icon(AppIcons.note, size: 18),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                    color: AppColors.surfaceOverlay,
                    borderRadius: AppRadius.input),
                child: Row(
                  children: [
                    Icon(AppIcons.recurring,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: Text('Periyodik',
                            style: AppTypography.titleSmall
                                .copyWith(color: AppColors.textPrimary))),
                    Switch.adaptive(
                      value: _isRecurring,
                      activeTrackColor: AppColors.expense,
                      onChanged: (v) => setState(() {
                        _isRecurring = v;
                        if (!v) _recurringEndDate = null;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expense,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.input),
                    elevation: 0,
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Kaydet',
                          style: AppTypography.labelLarge
                              .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Birikim Düzenleme ──────────────────────────────────────────────────

class EditSavingsSheet extends ConsumerStatefulWidget {
  final Savings savings;
  const EditSavingsSheet({super.key, required this.savings});

  @override
  ConsumerState<EditSavingsSheet> createState() => _EditSavingsSheetState();
}

class _EditSavingsSheetState extends ConsumerState<EditSavingsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late SavingsCategory _category;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final s = widget.savings;
    _amountController =
        TextEditingController(text: s.amount.toStringAsFixed(0));
    _noteController = TextEditingController(text: s.note ?? '');
    _category = s.category;
    _date = s.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(
        _amountController.text.replaceAll(',', '.').replaceAll(' ', ''));

    final updated = widget.savings.copyWith(
      amount: amount,
      category: _category,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    final success =
        await ref.read(transactionFormProvider.notifier).updateSavings(updated);
    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFB45309), Color(0xFFD97706)]),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(AppIcons.edit,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Birikim Düzenle',
                          style: AppTypography.headlineSmall
                              .copyWith(color: AppColors.textPrimary)),
                      Text('Mevcut birikim kaydını güncelle',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.savingsSurfaceDim,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                      color: AppColors.savings.withValues(alpha: 0.2)),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                  ],
                  style: AppTypography.numericLarge
                      .copyWith(color: AppColors.savingsStrong),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixText: '₺',
                    suffixStyle: AppTypography.numericMedium.copyWith(
                        color: AppColors.savings.withValues(alpha: 0.5)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Tutar giriniz';
                    final parsed = double.tryParse(
                        v.replaceAll(',', '.').replaceAll(' ', ''));
                    if (parsed == null || parsed <= 0) {
                      return 'Geçerli bir tutar giriniz';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              Text('Kategori',
                  style: AppTypography.labelMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: SavingsCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.savings
                            : AppColors.surfaceOverlay,
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                            color: isSelected
                                ? AppColors.savings
                                : AppColors.borderDefault),
                      ),
                      child: Text(cat.label,
                          style: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.base),

              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 366)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: _EditFieldChip(
                    icon: AppIcons.calendar, label: _formatDate(_date)),
              ),
              const SizedBox(height: AppSpacing.sm),

              TextFormField(
                controller: _noteController,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Not',
                  prefixIcon: Icon(AppIcons.note, size: 18),
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.savings,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.input),
                    elevation: 0,
                  ),
                  child: formState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Kaydet',
                          style: AppTypography.labelLarge
                              .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ortak Field Chip (Edit sheet'ler için) ─────────────────────────────

class _EditFieldChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EditFieldChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
