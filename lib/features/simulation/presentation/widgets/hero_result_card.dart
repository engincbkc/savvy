import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class HeroResultCard extends StatelessWidget {
  final double monthlyImpact;
  final Color color;
  final bool isRent;

  const HeroResultCard({
    super.key,
    required this.monthlyImpact,
    required this.color,
    this.isRent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardLg,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isRent ? 'AYLIK KİRA FARKI' : 'AYLIK TAKSİT',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: monthlyImpact),
            duration: AppDuration.countUp,
            curve: AppCurve.enter,
            builder: (_, val, _) => Text(
              CurrencyFormatter.formatNoDecimal(val),
              style: AppTypography.numericHero
                  .copyWith(color: Colors.white, fontSize: 36),
            ),
          ),
          Text(
            isRent ? 'aylık ek yük' : 'aylık ödemeniz olacak',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
