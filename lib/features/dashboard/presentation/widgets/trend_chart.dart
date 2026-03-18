import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/core/utils/year_month_helper.dart';

class TrendChart extends StatelessWidget {
  final List<MonthSummary> projections;

  const TrendChart({super.key, required this.projections});

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) return const SizedBox.shrink();

    final maxVal = projections
        .map((p) => p.netWithCarryOver.abs())
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Kümülatif Trend',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.of(context).textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '12 ay',
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.of(context).surfaceCard,
            borderRadius: AppRadius.card,
            boxShadow: AppShadow.sm,
          ),
          child: SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: projections.map((p) {
                  final ratio =
                      maxVal > 0 ? (p.netWithCarryOver.abs() / maxVal) : 0.0;
                  final isPositive = p.netWithCarryOver >= 0;

                  return SizedBox(
                    width: 64,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              CurrencyFormatter.compact(
                                  p.netWithCarryOver),
                              style: AppTypography.caption.copyWith(
                                color: isPositive
                                    ? AppColors.of(context).income
                                    : AppColors.of(context).expense,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: AppDuration.slow,
                          curve: AppCurve.decelerate,
                          width: 32,
                          height: (110 * ratio).clamp(8.0, 110.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPositive
                                  ? [
                                      AppColors.of(context).income
                                          .withValues(alpha: 0.4),
                                      AppColors.of(context).income,
                                    ]
                                  : [
                                      AppColors.of(context).expense
                                          .withValues(alpha: 0.4),
                                      AppColors.of(context).expense,
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          MonthLabels.short(p.yearMonth)
                              .split(' ')[0],
                          style: AppTypography.caption.copyWith(
                            color: AppColors.of(context).textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
