import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class DetailHeroCard extends StatelessWidget {
  final double netWithCarryOver;
  final double netBalance;
  final double carryOver;

  const DetailHeroCard({
    super.key,
    required this.netWithCarryOver,
    required this.netBalance,
    required this.carryOver,
  });

  List<Color> get _gradient {
    if (netWithCarryOver > 0) {
      return [const Color(0xFF064E3B), const Color(0xFF059669)];
    } else if (netWithCarryOver < 0) {
      return [const Color(0xFF7F1D1D), const Color(0xFFDC2626)];
    } else {
      return [AppColors.brandPrimaryDim, AppColors.brandPrimary];
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Label
          Text(
            'KÜMÜLATİF BAKİYE',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textInverse.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Big number
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: netWithCarryOver),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, child) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericHero.copyWith(
                color: AppColors.textInverse,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Breakdown row
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.textInverse.withValues(alpha: 0.1),
              borderRadius: AppRadius.chip,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                HeroStat(
                  label: 'Aylık Net',
                  value: CurrencyFormatter.formatNoDecimal(netBalance),
                  color: netBalance >= 0
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFCA5A5),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.textInverse.withValues(alpha: 0.2),
                ),
                HeroStat(
                  label: 'Devir',
                  value: CurrencyFormatter.formatNoDecimal(carryOver),
                  color: carryOver >= 0
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFCA5A5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const HeroStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textInverse.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.numericSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
