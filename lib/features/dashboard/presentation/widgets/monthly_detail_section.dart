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

/// Aylık Detay bölümü — seçili ayın işlemlerini ve özetini gösterir.
class MonthlyDetailSection extends ConsumerWidget {
  const MonthlyDetailSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYm = ref.watch(selectedYearMonthProvider);
    final summary = ref.watch(monthSummaryProvider(selectedYm));
    final incomesAsync = ref.watch(monthIncomesProvider(selectedYm));
    final expensesAsync = ref.watch(monthExpensesProvider(selectedYm));
    final savingsAsync = ref.watch(monthSavingsProvider(selectedYm));

    final now = DateTime.now();
    final nowYm = now.toYearMonth();
    final isFuture = selectedYm.compareTo(nowYm) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──
        _SectionHeader(
          yearMonth: selectedYm,
          isFuture: isFuture,
          onPrevious: () {
            HapticFeedback.selectionClick();
            final parts = selectedYm.split('-');
            final y = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final prev = DateTime(y, m - 1, 1);
            ref.read(selectedYearMonthProvider.notifier).set(prev.toYearMonth());
          },
          onNext: () {
            HapticFeedback.selectionClick();
            final parts = selectedYm.split('-');
            final y = int.parse(parts[0]);
            final m = int.parse(parts[1]);
            final next = DateTime(y, m + 1, 1);
            ref.read(selectedYearMonthProvider.notifier).set(next.toYearMonth());
          },
          onCompare: () {
            HapticFeedback.lightImpact();
            context.push('/dashboard/compare?month=$selectedYm');
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Özet Satırı ──
        if (summary != null)
          _SummaryRow(
            totalIncome: summary.totalIncome,
            totalExpense: summary.totalExpense,
            net: summary.netBalance,
            cumulative: summary.netWithCarryOver,
          ),

        const SizedBox(height: AppSpacing.base),

        // ── İşlem Listesi ──
        _TransactionList(
          incomesAsync: incomesAsync,
          expensesAsync: expensesAsync,
          savingsAsync: savingsAsync,
          selectedYm: selectedYm,
        ),
      ],
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String yearMonth;
  final bool isFuture;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCompare;

  const _SectionHeader({
    required this.yearMonth,
    required this.isFuture,
    required this.onPrevious,
    required this.onNext,
    required this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Row(
      children: [
        Container(
          width: 2,
          height: 16,
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: c.brandPrimary,
            borderRadius: AppRadius.pill,
          ),
        ),
        Text(
          'Aylık Detay',
          style: AppTypography.headlineSmall.copyWith(
            color: c.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Ay adı chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.brandPrimary.withValues(alpha: 0.08),
            borderRadius: AppRadius.pill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MonthLabels.full(yearMonth),
                style: AppTypography.labelSmall.copyWith(
                  color: c.brandPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              if (isFuture) ...[
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: c.warning.withValues(alpha: 0.15),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    'tahmini',
                    style: AppTypography.caption.copyWith(
                      color: c.warning,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        // Karşılaştır ikonu
        GestureDetector(
          onTap: onCompare,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: c.surfaceOverlay,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              LucideIcons.gitCompare,
              size: 14,
              color: c.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Chevronlar
        GestureDetector(
          onTap: onPrevious,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: c.surfaceOverlay,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 18,
              color: c.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onNext,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: c.surfaceOverlay,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: c.textSecondary,
            ),
          ),
        ),
      ],
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
        _SummaryChip(
          label: 'Gelir',
          value: totalIncome,
          color: c.income,
        ),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
          label: 'Gider',
          value: totalExpense,
          color: c.expense,
        ),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
          label: 'Net',
          value: net,
          color: net >= 0 ? c.income : c.expense,
        ),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
          label: 'Küm.',
          value: cumulative,
          color: cumulative >= 0 ? c.income : c.expense,
        ),
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
  final AsyncValue<List<dynamic>> incomesAsync;
  final AsyncValue<List<dynamic>> expensesAsync;
  final AsyncValue<List<dynamic>> savingsAsync;
  final String selectedYm;

  const _TransactionList({
    required this.incomesAsync,
    required this.expensesAsync,
    required this.savingsAsync,
    required this.selectedYm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final isLoading = incomesAsync.isLoading ||
        expensesAsync.isLoading ||
        savingsAsync.isLoading;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final incomes = incomesAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];
    final savings = savingsAsync.value ?? [];

    if (incomes.isEmpty && expenses.isEmpty && savings.isEmpty) {
      return _EmptyMonthState(selectedYm: selectedYm);
    }

    final allItems = <_DetailTxItem>[
      ...incomes.map((i) => _DetailTxItem(
            id: i.id,
            title: i.category.label,
            note: i.note,
            amount: i.amount,
            type: _TxType.income,
            date: i.date,
            isSettled: i.isSettled,
          )),
      ...expenses.map((e) => _DetailTxItem(
            id: e.id,
            title: e.category.label,
            note: e.note,
            amount: e.amount,
            type: _TxType.expense,
            date: e.date,
            isSettled: e.isSettled,
          )),
      ...savings.map((s) => _DetailTxItem(
            id: s.id,
            title: s.category.label,
            note: s.note,
            amount: s.amount,
            type: _TxType.savings,
            date: s.date,
            isSettled: true, // savings always settled
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

        // Tick label
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
              // Icon
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
              // Title + date
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
              // Amount + settle tick
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
                      onTap: () => _toggleSettled(ref, item),
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

  void _toggleSettled(WidgetRef ref, _DetailTxItem item) {
    HapticFeedback.lightImpact();
    final newValue = !item.isSettled;
    switch (item.type) {
      case _TxType.income:
        ref.read(incomeRepositoryProvider).setSettled(item.id, newValue);
      case _TxType.expense:
        ref.read(expenseRepositoryProvider).setSettled(item.id, newValue);
      case _TxType.savings:
        break;
    }
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────

class _EmptyMonthState extends StatelessWidget {
  final String selectedYm;

  const _EmptyMonthState({required this.selectedYm});

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

class _DetailTxItem {
  final String id;
  final String title;
  final String? note;
  final double amount;
  final _TxType type;
  final DateTime date;
  final bool isSettled;

  _DetailTxItem({
    required this.id,
    required this.title,
    this.note,
    required this.amount,
    required this.type,
    required this.date,
    required this.isSettled,
  });
}
