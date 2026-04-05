import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/budget/domain/models/budget_limit.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetLimit limit;
  final double spent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetProgressCard({
    super.key,
    required this.limit,
    required this.spent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final ratio = limit.monthlyLimit > 0 ? spent / limit.monthlyLimit : 0.0;
    final pct = (ratio * 100).clamp(0.0, 999.0);
    final isOver = ratio > 1.0;

    final progressColor = _progressColor(ratio, colors);
    final progressBg = _progressBg(ratio, colors);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isOver
              ? colors.error.withValues(alpha: 0.3)
              : colors.borderDefault,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + name + amounts + actions
            Row(
              children: [
                // Category icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Icon(
                    limit.category.icon,
                    size: 20,
                    color: progressColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Category name + percentage
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        limit.category.label,
                        style: AppTypography.titleMedium
                            .copyWith(color: colors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '%${pct.toStringAsFixed(0)} kullanıldı',
                        style: AppTypography.caption
                            .copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Amounts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatNoDecimal(spent),
                      style: AppTypography.numericSmall.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '/ ${CurrencyFormatter.formatNoDecimal(limit.monthlyLimit)}',
                      style: AppTypography.caption
                          .copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                // Actions menu
                PopupMenuButton<_Action>(
                  icon: Icon(Icons.more_vert,
                      size: 20, color: colors.textTertiary),
                  onSelected: (action) {
                    if (action == _Action.edit) onEdit();
                    if (action == _Action.delete) onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _Action.edit,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 16, color: colors.textSecondary),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Düzenle',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: colors.textPrimary)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _Action.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 16, color: colors.error),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Sil',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: colors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress bar
            ClipRRect(
              borderRadius: AppRadius.pill,
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: progressBg,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            if (isOver) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 14, color: colors.error),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${CurrencyFormatter.formatNoDecimal(spent - limit.monthlyLimit)} limit aşıldı!',
                    style: AppTypography.caption
                        .copyWith(color: colors.error, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _progressColor(double ratio, dynamic colors) {
    if (ratio > 1.0) return colors.error as Color;
    if (ratio > 0.8) return colors.warning as Color;
    if (ratio > 0.6) return colors.savings as Color;
    return colors.income as Color;
  }

  Color _progressBg(double ratio, dynamic colors) {
    if (ratio > 1.0) return (colors.error as Color).withValues(alpha: 0.12);
    if (ratio > 0.8) return (colors.warning as Color).withValues(alpha: 0.12);
    if (ratio > 0.6) return (colors.savings as Color).withValues(alpha: 0.12);
    return (colors.income as Color).withValues(alpha: 0.12);
  }
}

enum _Action { edit, delete }
