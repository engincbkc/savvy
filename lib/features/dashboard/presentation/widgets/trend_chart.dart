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
  final List<double> goalTargets;

  const TrendChart({
    super.key,
    required this.projections,
    this.goalTargets = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) return const SizedBox.shrink();

    final allValues = projections.map((p) => p.netWithCarryOver.abs()).toList();
    for (final t in goalTargets) {
      allValues.add(t.abs());
    }
    final maxVal = allValues.reduce((a, b) => a > b ? a : b);

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
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.swipe_rounded,
                size: 14, color: AppColors.of(context).textTertiary),
            const SizedBox(width: 4),
            Text(
              'Kaydır',
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textTertiary,
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = 110.0;
                return Stack(
                  children: [
                    // Dashed goal lines
                    ...goalTargets.map((target) {
                      if (maxVal <= 0) return const SizedBox.shrink();
                      final ratio = (target / maxVal).clamp(0.0, 1.0);
                      final yPos = chartHeight * (1 - ratio) + 24;
                      return Positioned(
                        left: 0,
                        right: 0,
                        top: yPos,
                        child: _DashedLine(
                          color: AppColors.of(context).savings,
                          label: CurrencyFormatter.compact(target),
                        ),
                      );
                    }),
                    // Bars
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: projections.map((p) {
                          final ratio = maxVal > 0
                              ? (p.netWithCarryOver.abs() / maxVal)
                              : 0.0;
                          final isPositive = p.netWithCarryOver >= 0;

                          return SizedBox(
                            width: 64,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Text(
                                      CurrencyFormatter.compact(
                                          p.netWithCarryOver),
                                      style:
                                          AppTypography.caption.copyWith(
                                        color: isPositive
                                            ? AppColors.of(context).income
                                            : AppColors.of(context)
                                                .expense,
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
                                  height:
                                      (chartHeight * ratio).clamp(8.0, chartHeight),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPositive
                                          ? [
                                              AppColors.of(context)
                                                  .income
                                                  .withValues(alpha: 0.4),
                                              AppColors.of(context).income,
                                            ]
                                          : [
                                              AppColors.of(context)
                                                  .expense
                                                  .withValues(alpha: 0.4),
                                              AppColors.of(context)
                                                  .expense,
                                            ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius:
                                        const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  MonthLabels.short(p.yearMonth)
                                      .split(' ')[0],
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.of(context)
                                        .textTertiary,
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
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color color;
  final String label;

  const _DashedLine({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashPainter(color: color.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + dashWidth, size.height / 2),
        paint,
      );
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
