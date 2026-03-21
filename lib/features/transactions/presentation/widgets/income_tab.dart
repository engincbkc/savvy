import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/transactions/presentation/widgets/delete_dialog.dart';
import 'package:savvy/features/transactions/domain/models/income.dart';
import 'package:savvy/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:savvy/features/transactions/presentation/screens/edit_income_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/category_icons.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_detail_sheet.dart';
import 'package:savvy/features/transactions/presentation/widgets/monthly_category_table.dart';
import 'package:savvy/features/transactions/presentation/widgets/swipeable_transaction_tile.dart';
import 'package:savvy/features/transactions/presentation/widgets/transaction_shared_widgets.dart';
import 'package:savvy/shared/widgets/empty_state.dart';
import 'package:savvy/shared/widgets/salary_breakdown_panel.dart';

class IncomeTab extends ConsumerWidget {
  final List<Income> incomes;
  final List<Income> allIncomes;
  final double total;
  /// 1-indexed month for gross→net resolution (1=Ocak, 12=Aralık)
  final int displayMonth;

  const IncomeTab({
    super.key,
    required this.incomes,
    required this.allIncomes,
    required this.total,
    required this.displayMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (incomes.isEmpty) {
      return const EmptyState(
        icon: AppIcons.income,
        title: 'Henüz gelir yok',
        subtitle: 'İlk gelirini ekleyerek başlayabilirsin.',
      );
    }

    // Brüt ve normal gelirleri ayır
    final grossIncomes = incomes.where((i) => i.isGross).toList();
    // Eski brüt kayıtları tespit et (note'da "Brüt:" içerenler, isGross=false)
    final legacyGrossIncomes = incomes
        .where((i) => !i.isGross && i.note != null && i.note!.contains('Brüt:'))
        .toList();
    final regularIncomes = incomes
        .where((i) => !i.isGross && !(i.note != null && i.note!.contains('Brüt:')))
        .toList();

    // Kategori gruplama
    final grouped = <IncomeCategory, List<Income>>{};
    for (final i in incomes) {
      grouped.putIfAbsent(i.category, () => []).add(i);
    }
    final sortedCats = grouped.entries.toList()
      ..sort((a, b) {
        final aT = a.value.fold(0.0, (s, i) => s + _resolveAmount(i));
        final bT = b.value.fold(0.0, (s, i) => s + _resolveAmount(i));
        return bT.compareTo(aT);
      });

    // Monthly breakdown data
    final monthlyData = buildMonthlyCategoryData<Income>(
      allIncomes,
      (i) => i.person != null && i.person!.isNotEmpty
          ? '${i.person} ${i.category.label}'
          : i.category.label,
      (i) => incomeIcon(i.category),
      (i) => i.date,
      (i) => _resolveAmount(i),
      isRecurring: (i) => i.isRecurring,
      getRecurringEndDate: (i) => i.recurringEndDate,
      getAmountForMonth: (i, month) => FinancialCalculator.resolveNetForMonth(
        amount: i.amount, isGross: i.isGross, month: month,
      ),
      isYearBounded: (i) => i.isGross,
    );

    final displayCount = grossIncomes.length + regularIncomes.length + legacyGrossIncomes.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 100),
      children: [
        SummaryCard(
          title: 'Toplam Gelir',
          total: total,
          color: AppColors.of(context).income,
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          icon: AppIcons.income,
          itemCount: displayCount,
          categoryCount: grouped.length,
        ),
        const SizedBox(height: AppSpacing.lg),

        // Aylık kategori tablosu
        if (monthlyData.months.length > 1)
          MonthlyCategoryTable(
            data: monthlyData,
            color: AppColors.of(context).income,
          ),
        if (monthlyData.months.length > 1)
          const SizedBox(height: AppSpacing.xl),

        // Eski brüt kayıt temizleme banner'ı
        if (legacyGrossIncomes.isNotEmpty)
          _LegacyGrossCleanupBanner(
            count: legacyGrossIncomes.length,
            color: AppColors.of(context).income,
            onCleanup: () => _cleanupLegacyGross(context, ref, legacyGrossIncomes),
          ),
        if (legacyGrossIncomes.isNotEmpty)
          const SizedBox(height: AppSpacing.base),

        // Brüt Maaş Kartları (premium grouped card)
        ...grossIncomes.map((i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              child: _GrossSalaryCard(
                income: i,
                displayMonth: displayMonth,
                color: AppColors.of(context).income,
                onDelete: () => _confirmDelete(context, ref, i.id, 'brüt maaş'),
                onTap: () => _showDetail(context, i),
              ),
            )),

        if (regularIncomes.isNotEmpty) ...[
          SectionHeader(
              title: grossIncomes.isNotEmpty ? 'Diğer Gelirler' : 'Tüm Gelirler',
              count: regularIncomes.length),
          const SizedBox(height: AppSpacing.sm),
        ],
        ...regularIncomes.map((i) {
          final netAmount = _resolveAmount(i);
          return SwipeableTransactionTile(
              key: ValueKey(i.id),
              id: i.id,
              title: i.category.label,
              subtitle: i.note,
              amount: netAmount,
              date: i.date,
              color: AppColors.of(context).income,
              icon: incomeIcon(i.category),
              isRecurring: i.isRecurring,
              person: i.person,
              onDelete: () => _confirmDelete(context, ref, i.id, 'gelir'),
              onTap: () => _showDetail(context, i),
            );
        }),

        const SizedBox(height: AppSpacing.lg),

        // Kategoriler — Akordiyon
        CategoryAccordion(
          title: 'Kategorilere Göre',
          count: grouped.length,
          color: AppColors.of(context).income,
          children: sortedCats.map((entry) {
            final catTotal = entry.value.fold(0.0, (s, i) => s + _resolveAmount(i));
            return CategoryRow(
              icon: incomeIcon(entry.key),
              label: entry.key.label,
              amount: catTotal,
              percentage: total > 0 ? catTotal / total : 0.0,
              color: AppColors.of(context).income,
              count: entry.value.length,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String type) {
    showDeleteConfirmation(
      context: context,
      type: type,
      onConfirm: () => ref.read(transactionFormProvider.notifier).deleteIncome(id),
    );
  }

  void _cleanupLegacyGross(
      BuildContext context, WidgetRef ref, List<Income> legacyIncomes) {
    showDeleteConfirmation(
      context: context,
      type: '${legacyIncomes.length} eski brüt kayıt',
      onConfirm: () {
        final ids = legacyIncomes.map((i) => i.id).toList();
        ref.read(transactionFormProvider.notifier).deleteMultipleIncomes(ids);
      },
    );
  }

  double _resolveAmount(Income income) =>
      FinancialCalculator.resolveNetForMonth(
        amount: income.amount, isGross: income.isGross, month: displayMonth);

  void _showDetail(BuildContext context, Income income) {
    showModalBottomSheet(useRootNavigator: true, 
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(sheetCtx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: TransactionDetailSheet(
          title: income.isGross ? 'Gelir (Brüt Maaş)' : 'Gelir',
          categoryLabel: income.category.label,
          categoryIcon: incomeIcon(income.category),
          amount: _resolveAmount(income),
          date: income.date,
          color: AppColors.of(context).income,
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          note: income.note,
          person: income.person,
          isRecurring: income.isRecurring,
          recurringEndDate: income.recurringEndDate,
          onEdit: () => _showEdit(context, income),
        ),
      ),
    );
  }

  void _showEdit(BuildContext context, Income income) {
    showModalBottomSheet(useRootNavigator: true, 
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(sheetCtx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: EditIncomeSheet(income: income),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Gross Salary Card — premium grouped card for brüt maaş
// ═══════════════════════════════════════════════════════════════════

class _GrossSalaryCard extends StatefulWidget {
  final Income income;
  final int displayMonth;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _GrossSalaryCard({
    required this.income,
    required this.displayMonth,
    required this.color,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<_GrossSalaryCard> createState() => _GrossSalaryCardState();
}

class _GrossSalaryCardState extends State<_GrossSalaryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final breakdown = FinancialCalculator.calculateAnnualNetSalary(
        grossMonthly: widget.income.amount);
    final currentNet = breakdown.months[widget.displayMonth - 1].netTakeHome;
    final monthName = FinancialCalculator.monthNamesTR[widget.displayMonth - 1];

    return Dismissible(
      key: ValueKey(widget.income.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        widget.onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.expense,
          borderRadius: AppRadius.cardLg,
        ),
        child: const Icon(AppIcons.delete, color: Colors.white, size: 20),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      widget.color.withValues(alpha: 0.12),
                      widget.color.withValues(alpha: 0.04),
                    ]
                  : [
                      widget.color.withValues(alpha: 0.06),
                      widget.color.withValues(alpha: 0.02),
                    ],
            ),
            borderRadius: AppRadius.cardLg,
            border: Border.all(
              color: widget.color.withValues(alpha: isDark ? 0.2 : 0.12),
            ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color,
                          widget.color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: AppRadius.chip,
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.income.person != null &&
                                        widget.income.person!.isNotEmpty
                                    ? '${widget.income.person} Brüt Maaş'
                                    : 'Brüt Maaş',
                                style: AppTypography.titleMedium.copyWith(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.color.withValues(alpha: 0.12),
                                borderRadius: AppRadius.pill,
                              ),
                              child: Text(
                                'Periyodik',
                                style: AppTypography.caption.copyWith(
                                  color: widget.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Brüt ${CurrencyFormatter.formatNoDecimal(widget.income.amount)}',
                          style: AppTypography.caption.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Net amount for current month
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatNoDecimal(currentNet),
                        style: AppTypography.numericMedium.copyWith(
                          color: widget.color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '$monthName net',
                        style: AppTypography.caption.copyWith(
                          color: c.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mini month strip
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final m = breakdown.months[index];
                  final isCurrentMonth = index == widget.displayMonth - 1;
                  return Container(
                    width: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrentMonth
                          ? widget.color.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: AppRadius.chip,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          m.monthShortName,
                          style: AppTypography.caption.copyWith(
                            color: isCurrentMonth
                                ? widget.color
                                : c.textTertiary,
                            fontSize: 8,
                            fontWeight: isCurrentMonth
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.compact(m.netTakeHome),
                          style: AppTypography.caption.copyWith(
                            color: isCurrentMonth
                                ? widget.color
                                : c.textSecondary,
                            fontSize: 9,
                            fontWeight: isCurrentMonth
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Expand/collapse button
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _expanded ? 'Gizle' : 'Detayları Gör',
                      style: AppTypography.caption.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: widget.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded breakdown
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: SalaryBreakdownPanel(
                  breakdown: breakdown,
                  selectedMonthIndex: widget.displayMonth - 1,
                  onMonthSelected: (_) {},
                  accentColor: widget.color,
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Legacy Gross Cleanup Banner
// ═══════════════════════════════════════════════════════════════════

class _LegacyGrossCleanupBanner extends StatelessWidget {
  final int count;
  final Color color;
  final VoidCallback onCleanup;

  const _LegacyGrossCleanupBanner({
    required this.count,
    required this.color,
    required this.onCleanup,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eski brüt kayıtlar tespit edildi',
                  style: AppTypography.labelMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count ayrı kayıt var. Temizleyip tek brüt maaş kaydı oluşturabilirsin.',
                  style: AppTypography.caption.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onCleanup,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: AppRadius.chip,
              ),
              child: Text(
                'Temizle',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
