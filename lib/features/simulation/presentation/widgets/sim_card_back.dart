import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';

// ─── Back Card (Summary) ──────────────────────────────────────
class SimCardBack extends StatelessWidget {
  final SimulationEntry sim;

  const SimCardBack({super.key, required this.sim});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final typeColor = sim.template?.color ?? const Color(0xFF6B7280);
    final params = sim.parameters;
    final monthlyPayment =
        (params['monthlyPayment'] as num?)?.toDouble();
    final totalPayment =
        (params['totalPayment'] as num?)?.toDouble();
    final totalInterest =
        (params['totalInterest'] as num?)?.toDouble();
    final termMonths = (params['termMonths'] as num?)?.toInt();

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardLg,
        color: c.surfaceCard,
        border: Border.all(
          color: typeColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(sim.template?.icon ?? LucideIcons.sparkles, size: 18, color: typeColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    sim.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.rotateCcw,
                        size: 11, color: c.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Geri',
                      style: AppTypography.caption.copyWith(
                        color: c.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Divider(
              color: c.borderDefault.withValues(alpha: 0.3),
              height: AppSpacing.xl,
            ),

            // Summary 2x2 grid
            Row(
              children: [
                Expanded(
                  child: SimSummaryCell(
                    label: 'Aylık Taksit',
                    value: monthlyPayment != null
                        ? CurrencyFormatter.formatNoDecimal(
                            monthlyPayment)
                        : '-',
                    icon: LucideIcons.calendar,
                    color: c.brandPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SimSummaryCell(
                    label: 'Toplam Ödeme',
                    value: totalPayment != null
                        ? CurrencyFormatter.formatNoDecimal(
                            totalPayment)
                        : '-',
                    icon: LucideIcons.banknote,
                    color: c.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: SimSummaryCell(
                    label: 'Toplam Faiz',
                    value: totalInterest != null
                        ? CurrencyFormatter.formatNoDecimal(
                            totalInterest)
                        : '-',
                    icon: LucideIcons.percent,
                    color: c.expense,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SimSummaryCell(
                    label: 'Vade',
                    value:
                        termMonths != null ? '$termMonths ay' : '-',
                    icon: LucideIcons.clock,
                    color: c.savings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Cell ─────────────────────────────────────────────
class SimSummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SimSummaryCell({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceOverlay.withValues(alpha: 0.5),
        borderRadius: AppRadius.card,
        border:
            Border.all(color: c.borderDefault.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.numericMedium.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
