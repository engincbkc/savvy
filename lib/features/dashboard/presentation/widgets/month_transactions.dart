import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class MonthTransactions extends StatelessWidget {
  final AsyncValue<List<dynamic>> incomesAsync;
  final AsyncValue<List<dynamic>> expensesAsync;
  final AsyncValue<List<dynamic>> savingsAsync;

  const MonthTransactions({
    super.key,
    required this.incomesAsync,
    required this.expensesAsync,
    required this.savingsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = incomesAsync.isLoading ||
        expensesAsync.isLoading ||
        savingsAsync.isLoading;

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
    final savings = savingsAsync.value ?? [];

    final allItems = <TxItem>[
      ...incomes.map((i) => TxItem(
            title: i.category.label,
            note: i.note,
            amount: i.amount,
            type: TxType.income,
            date: i.date,
          )),
      ...expenses.map((e) => TxItem(
            title: e.category.label,
            note: e.note,
            amount: e.amount,
            type: TxType.expense,
            date: e.date,
          )),
      ...savings.map((s) => TxItem(
            title: s.category.label,
            note: s.note,
            amount: s.amount,
            type: TxType.savings,
            date: s.date,
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (allItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl2),
        child: Center(
          child: Text(
            'Bu ay henüz işlem yok',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: allItems.map((item) {
        final iconColor = switch (item.type) {
          TxType.income => AppColors.income,
          TxType.expense => AppColors.expense,
          TxType.savings => AppColors.savings,
        };
        final icon = switch (item.type) {
          TxType.income => AppIcons.income,
          TxType.expense => AppIcons.expense,
          TxType.savings => AppIcons.savings,
        };
        final prefix = switch (item.type) {
          TxType.income => '+',
          TxType.expense => '-',
          TxType.savings => '',
        };

        final dateStr =
            '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';

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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, color: AppColors.textInverse, size: 18),
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
                      item.note != null
                          ? '$dateStr · ${item.note}'
                          : dateStr,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '$prefix${CurrencyFormatter.formatNoDecimal(item.amount)}',
                style: AppTypography.numericSmall.copyWith(
                  color: iconColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

enum TxType { income, expense, savings }

class TxItem {
  final String title;
  final String? note;
  final double amount;
  final TxType type;
  final DateTime date;

  TxItem({
    required this.title,
    this.note,
    required this.amount,
    required this.type,
    required this.date,
  });
}
