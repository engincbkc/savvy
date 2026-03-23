import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';

class SimulationCard extends StatelessWidget {
  final SimulationEntry simulation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const SimulationCard({
    super.key,
    required this.simulation,
    required this.onTap,
    this.onLongPress,
  });

  Color _parseColor() {
    try {
      final hex = simulation.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return simulation.type.color;
    }
  }

  String? get _amountSummary {
    final p = simulation.parameters;
    final principal = p['principal'];
    if (principal != null && principal is num && principal > 0) {
      return CurrencyFormatter.formatNoDecimal(principal.toDouble());
    }
    final rent = p['currentRent'];
    if (rent != null && rent is num && rent > 0) {
      return CurrencyFormatter.formatNoDecimal(rent.toDouble());
    }
    return null;
  }

  String? get _termSummary {
    final p = simulation.parameters;
    final term = p['termMonths'];
    if (term != null && term is num && term > 0) {
      return '${term.toInt()} ay';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = _parseColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = _amountSummary;
    final term = _termSummary;
    final hasParams = simulation.parameters.isNotEmpty && amount != null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: onLongPress != null
          ? () {
              HapticFeedback.mediumImpact();
              onLongPress!();
            }
          : null,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: AppCurve.enter,
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.cardLg,
          border: Border.all(
            color: isDark
                ? color.withValues(alpha: 0.2)
                : c.borderDefault.withValues(alpha: 0.6),
          ),
          boxShadow: AppShadow.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Icon(
                  simulation.type.icon,
                  color: color,
                  size: 22,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Title + type + summary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      simulation.title,
                      style: AppTypography.titleLarge
                          .copyWith(color: c.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            simulation.type.label,
                            style: AppTypography.caption.copyWith(
                                color: color, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (hasParams) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            amount,
                            style: AppTypography.numericSmall.copyWith(
                                color: c.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                          if (term != null) ...[
                            Text(' · ',
                                style: AppTypography.caption
                                    .copyWith(color: c.textTertiary)),
                            Text(term,
                                style: AppTypography.caption.copyWith(
                                    color: c.textTertiary,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: c.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
