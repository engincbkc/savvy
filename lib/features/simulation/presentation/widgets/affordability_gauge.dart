import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';

class AffordabilityGauge extends StatelessWidget {
  final AffordabilityStatus status;
  final double ratio;

  const AffordabilityGauge({
    super.key,
    required this.status,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final clampedRatio = ratio.clamp(0.0, 1.0);

    final statusColor = switch (status) {
      AffordabilityStatus.comfortable => c.income,
      AffordabilityStatus.manageable => c.brandPrimary,
      AffordabilityStatus.tight => c.warning,
      AffordabilityStatus.risky => c.expense,
    };

    final statusIcon = switch (status) {
      AffordabilityStatus.comfortable => LucideIcons.checkCircle,
      AffordabilityStatus.manageable => LucideIcons.info,
      AffordabilityStatus.tight => LucideIcons.alertTriangle,
      AffordabilityStatus.risky => LucideIcons.alertOctagon,
    };

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
              Icon(LucideIcons.gauge, size: 16, color: statusColor),
              const SizedBox(width: AppSpacing.xs),
              Text('Karşılanabilirlik',
                  style: AppTypography.titleMedium
                      .copyWith(color: c.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.pill,
                  border:
                      Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 3),
                    Text(status.label,
                        style: AppTypography.caption.copyWith(
                            color: statusColor, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.income.withValues(alpha: 0.2),
                          c.warning.withValues(alpha: 0.2),
                          c.expense.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: clampedRatio,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: AppDuration.slow,
                      curve: AppCurve.enter,
                      builder: (_, val, child) => FractionallySizedBox(
                        widthFactor: val,
                        child: child,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [statusColor, statusColor],
                          ),
                          borderRadius: AppRadius.pill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gelirinizin',
                  style: AppTypography.caption
                      .copyWith(color: c.textTertiary)),
              Text(
                '%${(clampedRatio * 100).toStringAsFixed(1)}\'i taksit',
                style: AppTypography.labelSmall.copyWith(
                    color: statusColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _ThresholdChip(label: '<%25 Rahat', color: c.income),
              _ThresholdChip(label: '<%35 İdare', color: c.brandPrimary),
              _ThresholdChip(label: '<%45 Sıkışık', color: c.warning),
              _ThresholdChip(label: '≥%45 Risk', color: c.expense),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThresholdChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ThresholdChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.of(context).textTertiary, fontSize: 9),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
