import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class QuickSummaryChip extends StatelessWidget {
  final double net;
  const QuickSummaryChip({super.key, required this.net});

  @override
  Widget build(BuildContext context) {
    final isPositive = net >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.of(context).incomeSurface : AppColors.of(context).expenseSurface,
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: isPositive
              ? AppColors.of(context).income.withValues(alpha: 0.3)
              : AppColors.of(context).expense.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? AppIcons.income : AppIcons.expense,
            size: 14,
            color: isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
          ),
          const SizedBox(width: 4),
          Text(
            'Net: ${isPositive ? '+' : ''}${CurrencyFormatter.compact(net)}',
            style: AppTypography.labelSmall.copyWith(
              color: isPositive ? AppColors.of(context).incomeStrong : AppColors.of(context).expenseStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
