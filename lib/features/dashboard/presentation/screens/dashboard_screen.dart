import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/shared/widgets/financial_card.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _monthLabel(String yearMonth) {
    final parts = yearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    const months = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return '${months[month]} $year';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final summary = ref.watch(monthSummaryProvider(yearMonth));
    final incomesAsync = ref.watch(monthIncomesProvider(yearMonth));
    final expensesAsync = ref.watch(monthExpensesProvider(yearMonth));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Text(
              'Savvy',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.brandPrimary,
              ),
            ),
            centerTitle: false,
          ),

          // Content
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.base),

                // Net Balance Hero Card
                _NetBalanceHero(
                  netBalance: summary?.netBalance ?? 0,
                  yearMonth: _monthLabel(yearMonth),
                  healthScore: summary?.healthScore ?? 0,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Income / Expense / Savings cards row
                Row(
                  children: [
                    Expanded(
                      child: FinancialCard(
                        type: FinancialCardType.income,
                        amount: summary?.totalIncome ?? 0,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FinancialCard(
                        type: FinancialCardType.expense,
                        amount: summary?.totalExpense ?? 0,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: FinancialCard(
                        type: FinancialCardType.savings,
                        amount: summary?.totalSavings ?? 0,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Recent transactions header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Son İşlemler',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: Text(
                        'Tümü',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Recent transactions list
                _RecentTransactions(
                  incomesAsync: incomesAsync,
                  expensesAsync: expensesAsync,
                ),

                const SizedBox(height: AppSpacing.xl5),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetBalanceHero extends StatelessWidget {
  final double netBalance;
  final String yearMonth;
  final int healthScore;

  const _NetBalanceHero({
    required this.netBalance,
    required this.yearMonth,
    required this.healthScore,
  });

  List<Color> get _gradient {
    if (netBalance > 0) {
      return [AppColors.incomeStrong, AppColors.income];
    } else if (netBalance < 0) {
      return [AppColors.expenseStrong, AppColors.expense];
    } else {
      return [AppColors.brandPrimaryDim, AppColors.brandPrimary];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.hero,
      ),
      child: Column(
        children: [
          // Month selector + health score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                yearMonth,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textInverse.withValues(alpha: 0.2),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Sağlık: $healthScore',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // NET BALANCE label
          Text(
            'NET BAKİYE',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.7),
              letterSpacing: 2.0,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Amount with count-up animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: netBalance),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, child) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericHero.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final AsyncValue<List<dynamic>> incomesAsync;
  final AsyncValue<List<dynamic>> expensesAsync;

  const _RecentTransactions({
    required this.incomesAsync,
    required this.expensesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = incomesAsync.isLoading || expensesAsync.isLoading;
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

    final incomes = incomesAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];

    // Combine and sort by date (most recent first), take last 5
    final allItems = <_TransactionItem>[
      ...incomes.map((i) => _TransactionItem(
            title: i.category.label,
            amount: i.amount,
            isIncome: true,
            date: i.date,
          )),
      ...expenses.map((e) => _TransactionItem(
            title: e.category.label,
            amount: e.amount,
            isIncome: false,
            date: e.date,
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final recent = allItems.take(5).toList();

    if (recent.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl2),
          child: Column(
            children: [
              Icon(
                AppIcons.balance,
                size: 48,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Henüz işlem yok',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'İlk işlemini eklemek için + butonuna bas',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: recent.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          padding: AppSpacing.listTile,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.card,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.isIncome ? AppColors.income : AppColors.expense,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  item.isIncome ? AppIcons.income : AppIcons.expense,
                  color: AppColors.textInverse,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.isIncome ? '+' : '-'}${CurrencyFormatter.formatNoDecimal(item.amount)}',
                style: AppTypography.numericSmall.copyWith(
                  color: item.isIncome ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TransactionItem {
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;

  _TransactionItem({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });
}
