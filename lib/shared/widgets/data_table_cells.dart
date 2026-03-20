import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

/// Fixed left-side row label for horizontal data tables.
class DataTableRowLabel extends StatelessWidget {
  final String text;
  final double height;
  final bool bold;
  final Color? color;

  const DataTableRowLabel({
    super.key,
    required this.text,
    required this.height,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: color ?? AppColors.of(context).textSecondary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Currency value cell for horizontal data tables.
class DataTableCellValue extends StatelessWidget {
  final double value;
  final Color color;
  final double height;
  final bool bold;

  const DataTableCellValue({
    super.key,
    required this.value,
    required this.color,
    required this.height,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == 0
        ? '-'
        : CurrencyFormatter.formatNoDecimal(value);
    return SizedBox(
      height: height,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              text,
              style: AppTypography.numericSmall.copyWith(
                color: value == 0 ? AppColors.of(context).textTertiary : color,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Highlighted cumulative balance cell (bottom of column).
class DataTableCumulativeCell extends StatelessWidget {
  final double value;
  final double height;
  final double? goalTarget;

  const DataTableCumulativeCell({
    super.key,
    required this.value,
    this.height = 44,
    this.goalTarget,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    final reachedGoal = goalTarget != null && value >= goalTarget!;
    return Container(
      height: height,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.of(context).income.withValues(alpha: 0.08)
            : AppColors.of(context).expense.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(8),
        ),
        border: reachedGoal
            ? Border.all(
                color: AppColors.of(context).savings.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericSmall.copyWith(
                color: isPositive
                    ? AppColors.of(context).income
                    : AppColors.of(context).expense,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (goalTarget != null && !reachedGoal)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 16,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.of(context).savings.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          if (reachedGoal)
            Icon(Icons.flag_rounded,
                size: 10, color: AppColors.of(context).savings),
        ],
      ),
    );
  }
}
