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
  final String? prefix;
  final bool bold;

  const DataTableCellValue({
    super.key,
    required this.value,
    required this.color,
    required this.height,
    this.prefix,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == 0
        ? '-'
        : '${prefix ?? ''}${CurrencyFormatter.formatNoDecimal(value)}';
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

  const DataTableCumulativeCell({
    super.key,
    required this.value,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
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
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          CurrencyFormatter.formatNoDecimal(value),
          style: AppTypography.numericSmall.copyWith(
            color: isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
