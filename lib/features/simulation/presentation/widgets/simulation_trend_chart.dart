import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';

class SimulationTrendChart extends StatelessWidget {
  final List<MonthSummary> projections;

  const SimulationTrendChart({super.key, required this.projections});

  @override
  Widget build(BuildContext context) {
    final values = projections.map((p) => p.netWithCarryOver).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal).abs();
    final effectiveRange = range == 0 ? 1.0 : range;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.card,
        boxShadow: AppShadow.sm,
        border: Border.all(
          color: AppColors.of(context).borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kümülatif Bakiye Trendi',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: projections.asMap().entries.map((entry) {
                final idx = entry.key;
                final p = entry.value;
                final normalized =
                    ((p.netWithCarryOver - minVal) / effectiveRange)
                        .clamp(0.1, 1.0);

                final monthNum =
                    int.parse(p.yearMonth.split('-')[1]);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: idx == 0 ? 0 : 3,
                      right: idx == projections.length - 1 ? 0 : 3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyFormatter.formatNoDecimal(
                              p.netWithCarryOver),
                          style: AppTypography.caption.copyWith(
                            color: p.netWithCarryOver >= 0
                                ? AppColors.of(context).income
                                : AppColors.of(context).expense,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 80 * normalized,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: p.netWithCarryOver >= 0
                                  ? [
                                      const Color(0xFF059669),
                                      const Color(0xFF10B981),
                                    ]
                                  : [
                                      const Color(0xFFDC2626),
                                      const Color(0xFFEF4444),
                                    ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          MonthLabels.monthName(monthNum).substring(0, 3),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.of(context).textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
