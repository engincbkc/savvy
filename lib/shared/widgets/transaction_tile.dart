import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/shared/widgets/financial_card.dart';

class TransactionTile extends StatelessWidget {
  final FinancialCardType type;
  final IconData categoryIcon;
  final String title;
  final String? subtitle;
  final double amount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionTile({
    super.key,
    required this.type,
    required this.categoryIcon,
    required this.title,
    this.subtitle,
    required this.amount,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  Color get _iconBgColor => switch (type) {
        FinancialCardType.income => AppColors.income,
        FinancialCardType.expense => AppColors.expense,
        FinancialCardType.savings => AppColors.savings,
      };

  Color get _amountColor => switch (type) {
        FinancialCardType.income => AppColors.income,
        FinancialCardType.expense => AppColors.expense,
        FinancialCardType.savings => AppColors.savings,
      };

  String get _prefix => switch (type) {
        FinancialCardType.income => '+',
        FinancialCardType.expense => '-',
        FinancialCardType.savings => '',
      };

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('$title-$amount'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
          return false;
        } else {
          onEdit?.call();
          return false;
        }
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        color: AppColors.brandPrimary,
        child: const Icon(AppIcons.edit, color: AppColors.textInverse),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        color: AppColors.expense,
        child: const Icon(AppIcons.delete, color: AppColors.textInverse),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.listTile,
          child: Row(
            children: [
              // Category icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  categoryIcon,
                  color: AppColors.textInverse,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Amount
              Text(
                '$_prefix${CurrencyFormatter.formatNoDecimal(amount)}',
                style: AppTypography.numericSmall.copyWith(
                  color: _amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
