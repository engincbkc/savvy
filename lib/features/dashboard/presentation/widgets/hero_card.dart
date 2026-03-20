import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class HeroCard extends StatelessWidget {
  final double cumulativeNet;
  final MonthSummary? currentMonth;

  const HeroCard({
    super.key,
    required this.cumulativeNet,
    this.currentMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthNet = currentMonth != null
        ? currentMonth!.totalIncome - currentMonth!.totalExpense
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: const [
          BoxShadow(
            color: Color(0x401E293B),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle top shine
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status label
                Row(
                  children: [
                    // Glowing status dot
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cumulativeNet >= 0
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFCA5A5),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (cumulativeNet >= 0
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFCA5A5))
                                .withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Toplam Bakiye',
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Main amount — animated count-up
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: cumulativeNet),
                  duration: AppDuration.countUp,
                  curve: AppCurve.decelerate,
                  builder: (context, value, _) => Text(
                    CurrencyFormatter.formatNoDecimal(value),
                    style: AppTypography.numericHero.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.base),

                // Monthly delta pill
                if (monthNet != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          monthNet >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 13,
                          color: monthNet >= 0
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFFFCA5A5),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Bu ay ${monthNet >= 0 ? '+' : ''}${CurrencyFormatter.formatNoDecimal(monthNet)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: const Color(0xFFCBD5E1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
