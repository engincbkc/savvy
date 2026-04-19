import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/repository_providers.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class MonthlyDetailBreakdownScreen extends ConsumerStatefulWidget {
  const MonthlyDetailBreakdownScreen({super.key});

  @override
  ConsumerState<MonthlyDetailBreakdownScreen> createState() =>
      _MonthlyDetailBreakdownScreenState();
}

class _MonthlyDetailBreakdownScreenState
    extends ConsumerState<MonthlyDetailBreakdownScreen> {
  late String _selectedYm;

  @override
  void initState() {
    super.initState();
    _selectedYm = DateTime.now().toYearMonth();
  }

  void _goMonth(int delta) {
    HapticFeedback.selectionClick();
    final parts = _selectedYm.split('-');
    final y = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final d = DateTime(y, m + delta, 1);
    setState(() => _selectedYm = d.toYearMonth());
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final summary = ref.watch(monthSummaryProvider(_selectedYm));
    final allIncomesReady = ref.watch(allIncomesProvider);
    final allExpensesReady = ref.watch(allExpensesProvider);
    final savingsAsync = ref.watch(monthSavingsProvider(_selectedYm));

    final incomes = allIncomesReady.hasValue
        ? ref.watch(effectiveMonthIncomesProvider(_selectedYm))
        : <dynamic>[];
    final expenses = allExpensesReady.hasValue
        ? ref.watch(effectiveMonthExpensesProvider(_selectedYm))
        : <dynamic>[];
    final isLoadingTx = allIncomesReady.isLoading ||
        allExpensesReady.isLoading ||
        savingsAsync.isLoading;

    final nowYm = DateTime.now().toYearMonth();
    final isFuture = _selectedYm.compareTo(nowYm) > 0;

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── AppBar ──
            SliverAppBar(
              floating: true,
              backgroundColor: c.surfaceBackground,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.go('/dashboard'),
              ),
              title: Text(
                'Aylık Detay Dağılımı',
                style: AppTypography.headlineSmall.copyWith(
                  color: c.textPrimary,
                ),
              ),
              centerTitle: false,
              // actions: compare button — temporarily hidden
              // actions: [
              //   IconButton(
              //     icon: Icon(LucideIcons.gitCompare, color: c.textSecondary, size: 20),
              //     tooltip: 'Ay Karşılaştır',
              //     onPressed: () => context.push('/dashboard/compare?month=$_selectedYm'),
              //   ),
              // ],
            ),

            SliverPadding(
              padding: AppSpacing.screenH,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Month Picker ──
                  _MonthPicker(
                    yearMonth: _selectedYm,
                    isFuture: isFuture,
                    onPrevious: () => _goMonth(-1),
                    onNext: () => _goMonth(1),
                  ),

                  const SizedBox(height: AppSpacing.base),

                  // ── Summary Row ──
                  if (summary != null)
                    _SummaryRow(
                      totalIncome: summary.totalIncome,
                      totalExpense: summary.totalExpense,
                      net: summary.netBalance,
                      cumulative: summary.netWithCarryOver,
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── İşlemler başlığı ──
                  Text(
                    'İşlemler',
                    style: AppTypography.headlineSmall.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Transaction List ──
                  _TransactionList(
                    incomes: incomes,
                    expenses: expenses,
                    savingsAsync: savingsAsync,
                    isLoading: isLoadingTx,
                  ),

                  const SizedBox(height: AppSpacing.xl5),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Month Picker ────────────────────────────────────────────────────────

class _MonthPicker extends StatelessWidget {
  final String yearMonth;
  final bool isFuture;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthPicker({
    required this.yearMonth,
    required this.isFuture,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPrevious,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.surfaceOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: c.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                MonthLabels.full(yearMonth),
                style: AppTypography.titleMedium.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isFuture)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    'tahmini',
                    style: AppTypography.caption.copyWith(
                      color: c.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: c.surfaceOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Row ─────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double net;
  final double cumulative;

  const _SummaryRow({
    required this.totalIncome,
    required this.totalExpense,
    required this.net,
    required this.cumulative,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Row(
      children: [
        _SummaryChip(label: 'Gelir', value: totalIncome, color: c.income),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(label: 'Gider', value: totalExpense, color: c.expense),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
            label: 'Net',
            value: net,
            color: net >= 0 ? c.income : c.expense),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
            label: 'Küm.',
            value: cumulative,
            color: cumulative >= 0 ? c.income : c.expense),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: AppRadius.chip,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: c.textTertiary,
                fontSize: 9,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.formatNoDecimal(value),
                style: AppTypography.numericSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction List ────────────────────────────────────────────────────

class _TransactionList extends ConsumerWidget {
  final List<dynamic> incomes;
  final List<dynamic> expenses;
  final AsyncValue<List<dynamic>> savingsAsync;
  final bool isLoading;

  const _TransactionList({
    required this.incomes,
    required this.expenses,
    required this.savingsAsync,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);

    if (isLoading) {
      return const SavvyShimmer(
        child: Column(
          children: [
            ShimmerBox(height: 56),
            SizedBox(height: AppSpacing.xs),
            ShimmerBox(height: 56),
            SizedBox(height: AppSpacing.xs),
            ShimmerBox(height: 56),
          ],
        ),
      );
    }

    final savings = savingsAsync.value ?? [];

    if (incomes.isEmpty && expenses.isEmpty && savings.isEmpty) {
      return _EmptyState();
    }

    final allItems = <_TxItem>[
      ...incomes.map((i) => _TxItem(
            id: i.id,
            title: i.category.label,
            note: i.note,
            amount: i.amount,
            type: _TxType.income,
            date: i.date,
            isSettled: i.isSettled,
          )),
      ...expenses.map((e) => _TxItem(
            id: e.id,
            title: e.category.label,
            note: e.note,
            amount: e.amount,
            type: _TxType.expense,
            date: e.date,
            isSettled: e.isSettled,
          )),
      ...savings.map((s) => _TxItem(
            id: s.id,
            title: s.category.label,
            note: s.note,
            amount: s.amount,
            type: _TxType.savings,
            date: s.date,
            isSettled: true,
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: allItems.map((item) {
        final iconColor = switch (item.type) {
          _TxType.income => c.income,
          _TxType.expense => c.expense,
          _TxType.savings => c.savings,
        };
        final icon = switch (item.type) {
          _TxType.income => AppIcons.income,
          _TxType.expense => AppIcons.expense,
          _TxType.savings => AppIcons.savings,
        };
        final prefix = switch (item.type) {
          _TxType.income => '+',
          _TxType.expense => '-',
          _TxType.savings => '',
        };

        final dateStr =
            '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';

        final settledLabel = switch (item.type) {
          _TxType.income => item.isSettled ? 'Alındı' : 'Alınmadı',
          _TxType.expense => item.isSettled ? 'Ödendi' : 'Ödenmedi',
          _TxType.savings => '',
        };

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: AppSpacing.listTile,
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: AppRadius.card,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, color: c.textInverse, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      item.note != null
                          ? '$dateStr · ${item.note}'
                          : dateStr,
                      style: AppTypography.caption.copyWith(
                        color: c.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix${CurrencyFormatter.formatNoDecimal(item.amount)}',
                    style: AppTypography.numericSmall.copyWith(
                      color: iconColor,
                    ),
                  ),
                  if (item.type != _TxType.savings)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        final newVal = !item.isSettled;
                        switch (item.type) {
                          case _TxType.income:
                            ref
                                .read(incomeRepositoryProvider)
                                .setSettled(item.id, newVal);
                          case _TxType.expense:
                            ref
                                .read(expenseRepositoryProvider)
                                .setSettled(item.id, newVal);
                          case _TxType.savings:
                            break;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.isSettled
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 14,
                              color: item.isSettled
                                  ? AppColors.success
                                  : c.textTertiary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              settledLabel,
                              style: AppTypography.caption.copyWith(
                                color: item.isSettled
                                    ? AppColors.success
                                    : c.textTertiary,
                                fontSize: 10,
                                fontWeight: item.isSettled
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl2),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.calendarX,
              size: 36,
              color: c.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Bu ayda henüz işlem yok',
              style: AppTypography.bodyMedium.copyWith(
                color: c.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                context.go('/transactions');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: c.brandPrimary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'İşlem Ekle',
                  style: AppTypography.labelSmall.copyWith(
                    color: c.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Models ──────────────────────────────────────────────────────────────

enum _TxType { income, expense, savings }

class _TxItem {
  final String id;
  final String title;
  final String? note;
  final double amount;
  final _TxType type;
  final DateTime date;
  final bool isSettled;

  _TxItem({
    required this.id,
    required this.title,
    this.note,
    required this.amount,
    required this.type,
    required this.date,
    required this.isSettled,
  });
}
