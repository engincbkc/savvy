import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class CategoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final double percentage;
  final Color color;
  final int count;

  const CategoryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.input,
        border:
            Border.all(color: AppColors.of(context).borderDefault.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.of(context).textPrimary)),
                    Text('$count işlem',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.of(context).textTertiary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.formatNoDecimal(amount),
                      style: AppTypography.numericSmall
                          .copyWith(color: color, fontWeight: FontWeight.w700)),
                  Text('%${(percentage * 100).toStringAsFixed(1)}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.of(context).textTertiary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const SectionHeader({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: AppTypography.titleSmall.copyWith(
                color: AppColors.of(context).textSecondary, letterSpacing: 0.5)),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: AppColors.of(context).surfaceOverlay, borderRadius: AppRadius.pill),
          child: Text('$count',
              style: AppTypography.caption.copyWith(
                  color: AppColors.of(context).textTertiary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
