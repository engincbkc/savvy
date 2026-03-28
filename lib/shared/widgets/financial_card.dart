import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

enum FinancialCardType { income, expense, savings }

class FinancialCard extends StatelessWidget {
  final FinancialCardType type;
  final double amount;
  final double? changePercent;
  final VoidCallback? onTap;

  const FinancialCard({
    super.key,
    required this.type,
    required this.amount,
    this.changePercent,
    this.onTap,
  });

  Color get _color => switch (type) {
        FinancialCardType.income => AppColors.income,
        FinancialCardType.expense => AppColors.expense,
        FinancialCardType.savings => AppColors.savings,
      };

  Color get _surface => switch (type) {
        FinancialCardType.income => AppColors.incomeSurface,
        FinancialCardType.expense => AppColors.expenseSurface,
        FinancialCardType.savings => AppColors.savingsSurface,
      };

  List<BoxShadow> get _shadow => switch (type) {
        FinancialCardType.income => AppShadow.income,
        FinancialCardType.expense => AppShadow.expense,
        FinancialCardType.savings => AppShadow.savings,
      };

  IconData get _icon => switch (type) {
        FinancialCardType.income => AppIcons.income,
        FinancialCardType.expense => AppIcons.expense,
        FinancialCardType.savings => AppIcons.savings,
      };

  String get _label => switch (type) {
        FinancialCardType.income => 'Gelir',
        FinancialCardType.expense => 'Gider',
        FinancialCardType.savings => 'Birikim',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: amount),
        duration: AppDuration.countUp,
        curve: AppCurve.decelerate,
        builder: (context, value, child) {
          return Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: AppRadius.card,
              boxShadow: _shadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: AppRadius.chip,
                      ),
                      child: Icon(
                        _icon,
                        color: AppColors.textInverse,
                        size: AppIconSize.sm,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        _label,
                        style: AppTypography.titleSmall.copyWith(
                          color: _color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  CurrencyFormatter.formatNoDecimal(value),
                  style: AppTypography.numericLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (changePercent != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CurrencyFormatter.changePercent(changePercent!),
                    style: AppTypography.caption.copyWith(
                      color: changePercent! >= 0
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
