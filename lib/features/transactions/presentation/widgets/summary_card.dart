import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double total;
  final Color color;
  final List<Color> gradient;
  final IconData icon;
  final int itemCount;
  final int categoryCount;

  const SummaryCard({
    super.key,
    required this.title,
    required this.total,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.itemCount,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          children: [
            // Icon watermark in bottom-right
            Positioned(
              right: -AppSpacing.sm,
              bottom: -AppSpacing.sm,
              child: Icon(
                icon,
                size: 80,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            // Shine line at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.chip,
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(title,
                          style: AppTypography.titleMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85))),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: total),
                    duration: AppDuration.countUp,
                    curve: AppCurve.decelerate,
                    builder: (context, value, _) => Text(
                      CurrencyFormatter.formatNoDecimal(value),
                      style: AppTypography.numericLarge
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      MiniChip(
                        label: '$itemCount işlem',
                        bgColor: Colors.white.withValues(alpha: 0.15),
                        textColor: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      MiniChip(
                        label: '$categoryCount kategori',
                        bgColor: Colors.white.withValues(alpha: 0.15),
                        textColor: Colors.white.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const MiniChip(
      {super.key,
      required this.label,
      required this.bgColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: AppRadius.pill),
      child: Text(label,
          style: AppTypography.caption
              .copyWith(color: textColor, fontWeight: FontWeight.w500)),
    );
  }
}
