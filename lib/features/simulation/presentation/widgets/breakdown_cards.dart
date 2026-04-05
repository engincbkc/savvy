import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class BreakdownContainer extends StatelessWidget {
  final Color color;
  final List<Widget> children;

  const BreakdownContainer(
      {super.key, required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.receipt, size: 16, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text('Detay',
                  style: AppTypography.titleMedium
                      .copyWith(color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const BreakdownRow(this.label, this.value, this.valueColor, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
          Text(value,
              style: AppTypography.numericSmall
                  .copyWith(color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
