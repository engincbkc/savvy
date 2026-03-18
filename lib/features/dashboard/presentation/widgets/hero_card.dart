import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';

class HeroCard extends StatelessWidget {
  final double cumulativeNet;
  final int healthScore;

  const HeroCard({
    super.key,
    required this.cumulativeNet,
    required this.healthScore,
  });

  List<Color> get _gradient {
    if (cumulativeNet > 0) {
      return [const Color(0xFF064E3B), const Color(0xFF059669)];
    } else if (cumulativeNet < 0) {
      return [const Color(0xFF7F1D1D), const Color(0xFFDC2626)];
    }
    return [AppColors.brandPrimaryDim, AppColors.brandPrimary];
  }

  @override
  Widget build(BuildContext context) {
    final label = FinancialCalculator.healthScoreLabel(healthScore);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: AppShadow.hero,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOPLAM BAKIYE',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textInverse.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HealthIcon(score: healthScore, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$label · $healthScore',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: cumulativeNet),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, child) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericHero.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tüm zamanların kümülatif bakiyesi',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class HealthIcon extends StatelessWidget {
  final int score;
  final double size;
  const HealthIcon({super.key, required this.score, required this.size});

  @override
  Widget build(BuildContext context) {
    final icon = switch (score) {
      >= 80 => Icons.rocket_launch_rounded,
      >= 65 => Icons.trending_up_rounded,
      >= 50 => Icons.horizontal_rule_rounded,
      >= 35 => Icons.trending_down_rounded,
      _ => Icons.warning_rounded,
    };
    final color = switch (score) {
      >= 80 => AppColors.income,
      >= 65 => AppColors.brandPrimary,
      >= 50 => AppColors.warning,
      >= 35 => AppColors.savings,
      _ => AppColors.expense,
    };
    return Icon(icon, size: size, color: color);
  }
}
