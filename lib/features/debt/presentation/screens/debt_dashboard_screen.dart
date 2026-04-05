import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/transactions/domain/models/expense.dart';
import 'package:savvy/shared/widgets/empty_state.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class DebtDashboardScreen extends ConsumerWidget {
  const DebtDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpensesAsync = ref.watch(allExpensesProvider);

    if (allExpensesAsync.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: AppColors.of(context).surfaceBackground,
        body: const Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              ShimmerBox(height: 110),
              SizedBox(height: AppSpacing.base),
              ShimmerBox(height: 80),
              SizedBox(height: AppSpacing.base),
              ShimmerBox(height: 72),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 72),
              SizedBox(height: AppSpacing.sm),
              ShimmerBox(height: 72),
            ],
          ),
        ),
      );
    }

    final allExpenses = allExpensesAsync.value ?? [];
    final now = DateTime.now();

    final debtExpenses = allExpenses
        .where((e) =>
            e.isRecurring &&
            e.recurringEndDate != null &&
            e.recurringEndDate!.isAfter(now))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    if (debtExpenses.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: AppColors.of(context).surfaceBackground,
        body: const EmptyState(
          icon: LucideIcons.creditCard,
          title: 'Aktif taksitli borcunuz yok',
          subtitle:
              'Taksitli bir gider eklemek için "Periyodik" seçeneğini açıp bitiş tarihi belirleyin.',
        ),
      );
    }

    final totalRemaining =
        FinancialCalculator.totalRemainingDebt(allExpenses);
    final monthlyPayment =
        FinancialCalculator.monthlyDebtPayment(allExpenses);
    final freeDate = FinancialCalculator.debtFreeDate(allExpenses);

    return Scaffold(
      backgroundColor: AppColors.of(context).surfaceBackground,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          // Ozet kart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
              child: _DebtSummaryCard(
                totalRemaining: totalRemaining,
                monthlyPayment: monthlyPayment,
                freeDate: freeDate,
              ),
            ),
          ),

          // Borcussuz sayac
          if (freeDate != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
                child: _DebtFreeCountdown(freeDate: freeDate),
              ),
            ),

          // Bolum baslik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.creditCard,
                    size: 16,
                    color: AppColors.of(context).expense,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Taksitli Borçlar',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).expenseSurface,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      '${debtExpenses.length}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.of(context).expense,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Borc listesi
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _DebtItemTile(expense: debtExpenses[index]),
                ),
                childCount: debtExpenses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Borç Takibi',
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.of(context).textPrimary,
        ),
      ),
      backgroundColor: AppColors.of(context).surfaceBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          LucideIcons.chevronLeft,
          color: AppColors.of(context).textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Ozet Kart
// ═══════════════════════════════════════════════════════════════════════

class _DebtSummaryCard extends StatelessWidget {
  final double totalRemaining;
  final double monthlyPayment;
  final DateTime? freeDate;

  const _DebtSummaryCard({
    required this.totalRemaining,
    required this.monthlyPayment,
    required this.freeDate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    String freeDateStr;
    if (freeDate != null) {
      freeDateStr =
          '${freeDate!.month.toString().padLeft(2, '0')}/${freeDate!.year}';
    } else {
      freeDateStr = '—';
    }

    return Container(
      padding: AppSpacing.cardLg,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          _MetricColumn(
            label: 'Kalan Borç',
            value: CurrencyFormatter.formatNoDecimal(totalRemaining),
            valueColor: colors.expense,
          ),
          _VerticalDivider(color: colors.borderDefault),
          _MetricColumn(
            label: 'Aylık Taksit',
            value: CurrencyFormatter.formatNoDecimal(monthlyPayment),
            valueColor: colors.expense,
          ),
          _VerticalDivider(color: colors.borderDefault),
          _MetricColumn(
            label: 'Bitiş Tarihi',
            value: freeDateStr,
            valueColor: colors.income,
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _MetricColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.numericSmall.copyWith(color: valueColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.of(context).textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;
  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Borcssuz Sayac
// ═══════════════════════════════════════════════════════════════════════

class _DebtFreeCountdown extends StatelessWidget {
  final DateTime freeDate;

  const _DebtFreeCountdown({required this.freeDate});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final now = DateTime.now();
    final monthsLeft =
        (freeDate.year - now.year) * 12 + freeDate.month - now.month;
    final freeDateStr =
        '${freeDate.day.toString().padLeft(2, '0')}.${freeDate.month.toString().padLeft(2, '0')}.${freeDate.year}';

    return Container(
      padding: AppSpacing.cardLg,
      decoration: BoxDecoration(
        color: colors.incomeSurfaceDim,
        borderRadius: AppRadius.card,
        border: Border.all(color: colors.income.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.incomeSurface,
              borderRadius: AppRadius.card,
            ),
            child: Icon(
              LucideIcons.piggyBank,
              size: 22,
              color: colors.income,
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$monthsLeft Ay Sonra Borçsuz!',
                  style: AppTypography.titleLarge.copyWith(
                    color: colors.incomeStrong,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Son taksit: $freeDateStr',
                  style: AppTypography.bodySmall.copyWith(
                    color: colors.income,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Borc Tile
// ═══════════════════════════════════════════════════════════════════════

class _DebtItemTile extends StatelessWidget {
  final Expense expense;

  const _DebtItemTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final now = DateTime.now();
    final endDate = expense.recurringEndDate!;

    final totalMonths =
        (endDate.year - expense.date.year) * 12 +
        endDate.month - expense.date.month;
    final paidMonths =
        (now.year - expense.date.year) * 12 +
        now.month - expense.date.month;
    final progress =
        totalMonths > 0 ? (paidMonths / totalMonths).clamp(0.0, 1.0) : 0.0;

    final remainingMonths =
        ((endDate.year - now.year) * 12 + endDate.month - now.month)
            .clamp(0, 999);

    final title = expense.note?.isNotEmpty == true
        ? expense.note!
        : expense.category.label;

    final endDateStr =
        '${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ikon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.expenseSurface,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  expense.category.icon,
                  size: 18,
                  color: colors.expense,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Baslik & tutar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${CurrencyFormatter.formatNoDecimal(expense.amount)} / ay',
                      style: AppTypography.bodySmall.copyWith(
                        color: colors.expense,
                      ),
                    ),
                  ],
                ),
              ),

              // Kalan ay badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: remainingMonths <= 3
                      ? colors.expenseSurface
                      : colors.surfaceOverlay,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  '$remainingMonths ay kaldı',
                  style: AppTypography.labelSmall.copyWith(
                    color: remainingMonths <= 3
                        ? colors.expense
                        : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Ilerleme cubugu
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.expenseSurfaceDim,
              valueColor: AlwaysStoppedAnimation<Color>(colors.expense),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Alt bilgi: odenen taksit / toplam, bitis tarihi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${paidMonths.clamp(0, totalMonths)} / $totalMonths taksit',
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              Text(
                'Bitiş: $endDateStr',
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
