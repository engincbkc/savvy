import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/shared/widgets/info_tooltip.dart';

class HeroCard extends StatelessWidget {
  final double cumulativeNet;

  const HeroCard({
    super.key,
    required this.cumulativeNet,
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
                'TOPLAM BAKİYE',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              InfoTooltip(
                title: 'Toplam Bakiye',
                description:
                    'Tüm zamanların kümülatif bakiyesidir. Toplam gelirlerinizden toplam giderleriniz çıkarılarak hesaplanır.',
                size: 16,
                iconColor: AppColors.textInverse.withValues(alpha: 0.5),
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
