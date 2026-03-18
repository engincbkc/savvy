import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/core/utils/year_month_helper.dart';

class ProjectionTrendCard extends StatelessWidget {
  final List<MonthSummary> projections;
  final double currentBalance;

  const ProjectionTrendCard({
    super.key,
    required this.projections,
    required this.currentBalance,
  });

  @override
  Widget build(BuildContext context) {
    final endBalance = projections.last.netWithCarryOver;
    final diff = endBalance - currentBalance;
    final isPositive = diff >= 0;

    return Container(
      padding: AppSpacing.card,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '6 Ay Sonra Tahmini Bakiye',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: endBalance),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, child) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericHero.copyWith(
                color: endBalance >= 0 ? AppColors.of(context).income : AppColors.of(context).expense,
                fontSize: 32,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Diff badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.of(context).incomeSurface
                  : AppColors.of(context).expenseSurface,
              borderRadius: AppRadius.pill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? LucideIcons.trendingUp
                      : LucideIcons.trendingDown,
                  size: 14,
                  color: isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${CurrencyFormatter.formatNoDecimal(diff)} bugunle kıyasla',
                  style: AppTypography.caption.copyWith(
                    color: isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Mini bar chart
          ProjectionMiniBarChart(projections: projections),
        ],
      ),
    );
  }
}

class ProjectionMiniBarChart extends StatelessWidget {
  final List<MonthSummary> projections;

  const ProjectionMiniBarChart({super.key, required this.projections});

  @override
  Widget build(BuildContext context) {
    if (projections.isEmpty) return const SizedBox.shrink();

    final maxVal = projections
        .map((p) => p.netWithCarryOver.abs())
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: projections.map((p) {
          final ratio =
              maxVal > 0 ? (p.netWithCarryOver.abs() / maxVal) : 0.0;
          final isPositive = p.netWithCarryOver >= 0;
          final monthName = MonthLabels.full(p.yearMonth).split(' ')[0];
          // First 3 chars
          final shortMonth =
              monthName.length > 3 ? monthName.substring(0, 3) : monthName;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.compact(p.netWithCarryOver),
                    style: AppTypography.caption.copyWith(
                      color: isPositive ? AppColors.of(context).income : AppColors.of(context).expense,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: AppDuration.slow,
                    curve: AppCurve.decelerate,
                    height: (80 * ratio).clamp(8.0, 80.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPositive
                            ? [
                                AppColors.of(context).income.withValues(alpha: 0.6),
                                AppColors.of(context).income,
                              ]
                            : [
                                AppColors.of(context).expense.withValues(alpha: 0.6),
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
                  const SizedBox(height: 4),
                  Text(
                    shortMonth,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.of(context).textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
