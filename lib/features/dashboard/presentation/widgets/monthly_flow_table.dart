import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/shared/widgets/data_table_cells.dart';
import 'package:savvy/shared/widgets/info_tooltip.dart';

class MonthlyFlowTable extends StatefulWidget {
  final List<MonthSummary> summaries;
  final List<MonthSummary> projections;
  final bool includeSavings;
  final void Function(String yearMonth) onMonthTap;
  final double? nearestGoalTarget;

  const MonthlyFlowTable({
    super.key,
    required this.summaries,
    required this.projections,
    required this.includeSavings,
    required this.onMonthTap,
    this.nearestGoalTarget,
  });

  @override
  State<MonthlyFlowTable> createState() => _MonthlyFlowTableState();
}

class _MonthlyFlowTableState extends State<MonthlyFlowTable> {
  late ScrollController _scrollController;

  static const _colW = 80.0;
  static const _labelW = 56.0;
  static const _headerH = 40.0;
  static const _rowH = 48.0;
  static const _netH = 48.0;
  static const _cumH = 48.0;
  static const _dividerH = 1.0;

  @override
  void initState() {
    super.initState();
    final pastLen = widget.summaries.length;
    final initialOffset = pastLen > 3 ? (pastLen - 3) * _colW : 0.0;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pastSorted = widget.summaries.reversed.toList();
    final allMonths = [...pastSorted, ...widget.projections];
    if (allMonths.isEmpty) return const SizedBox.shrink();

    final rows = <FlowRowConfig>[
      FlowRowConfig('Gelir', AppIcons.income, AppColors.of(context).income),
      FlowRowConfig('Gider', AppIcons.expense, AppColors.of(context).expense),
      if (widget.includeSavings)
        FlowRowConfig(
            'Birikim', AppIcons.savings, AppColors.of(context).savings),
    ];

    final totalH = _headerH +
        _dividerH +
        (rows.length * _rowH) +
        _dividerH +
        _netH +
        _cumH;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            // Left accent line
            Container(
              width: 2,
              height: 16,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.of(context).brandPrimary,
                borderRadius: AppRadius.pill,
              ),
            ),
            Text(
              'Aylık Akış',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.of(context).textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.of(context).surfaceOverlay,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                '${pastSorted.length} geçmiş · ${widget.projections.length} tahmini',
                style: AppTypography.caption.copyWith(
                  color: AppColors.of(context).textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
            const Spacer(),
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

        // Table
        SizedBox(
          height: totalH,
          child: Row(
            children: [
              // Left labels — sticky
              SizedBox(
                width: _labelW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: _headerH),
                    const Divider(height: _dividerH),
                    ...rows.asMap().entries.map((e) {
                      final r = e.value;
                      final isOdd = e.key.isOdd;
                      final child = FlowLabel(
                        icon: r.icon,
                        label: r.label,
                        color: r.color,
                        height: _rowH,
                      );
                      if (isOdd) {
                        return Container(
                          color: AppColors.of(context)
                              .surfaceOverlay
                              .withValues(alpha: 0.3),
                          child: child,
                        );
                      }
                      return child;
                    }),
                    const Divider(height: _dividerH),
                    // Aylık Net — with info tooltip
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.of(context).brandPrimary.withValues(alpha: 0.03),
                      ),
                      height: _netH,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlowLabel(
                              icon: AppIcons.balance,
                              label: 'Net',
                              color: AppColors.of(context).textPrimary,
                              height: _netH,
                              bold: true,
                            ),
                          ),
                          InfoTooltip(
                            title: 'Aylık Net',
                            description:
                                'O aydaki toplam gelir ile toplam gider arasındaki farktır. Pozitif değer o ay kâra geçtiğinizi, negatif değer zararda olduğunuzu gösterir.',
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                    // Kümülatif — with info tooltip
                    SizedBox(
                      height: _cumH,
                      child: Row(
                        children: [
                          Expanded(
                            child: FlowLabel(
                              icon: AppIcons.networth,
                              label: 'Küm.',
                              color: AppColors.of(context).income,
                              height: _cumH,
                              bold: true,
                            ),
                          ),
                          InfoTooltip(
                            title: 'Kümülatif Bakiye',
                            description:
                                'Başlangıçtan itibaren biriken toplam net bakiyedir. Her ayın net tutarı bir önceki aya eklenerek hesaplanır.',
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable columns
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: allMonths.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final s = entry.value;
                      final isPast = idx < pastSorted.length;
                      final isCurrent =
                          isPast && idx == pastSorted.length - 1;
                      final displayNet = s.totalIncome - s.totalExpense;

                      return GestureDetector(
                        onTap: isPast
                            ? () => widget.onMonthTap(s.yearMonth)
                            : null,
                        child: Container(
                            width: _colW,
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.of(context)
                                      .brandPrimary
                                      .withValues(alpha: 0.05)
                                  : !isPast
                                      ? AppColors.of(context)
                                          .surfaceOverlay
                                          .withValues(alpha: 0.4)
                                      : Colors.transparent,
                              borderRadius: AppRadius.input,
                            ),
                            child: Column(
                              children: [
                                // Month header
                                SizedBox(
                                  height: _headerH,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            MonthLabels.short(s.yearMonth),
                                            style: AppTypography.labelSmall
                                                .copyWith(
                                              color: isCurrent
                                                  ? AppColors.of(context)
                                                      .brandPrimary
                                                  : isPast
                                                      ? AppColors.of(context)
                                                          .textPrimary
                                                      : AppColors.of(context)
                                                          .textTertiary,
                                              fontWeight: isCurrent
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                              fontSize: 11,
                                              decoration: isPast && !isCurrent
                                                  ? TextDecoration.underline
                                                  : null,
                                              decorationColor: AppColors.of(context)
                                                  .textTertiary
                                                  .withValues(alpha: 0.4),
                                              decorationStyle:
                                                  TextDecorationStyle.dotted,
                                            ),
                                          ),
                                          if (isCurrent)
                                            Container(
                                              width: 18,
                                              height: 2,
                                              margin: const EdgeInsets.only(top: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.of(context).brandPrimary,
                                                borderRadius: AppRadius.pill,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (!isPast)
                                        Text(
                                          'tahmini',
                                          style: AppTypography.caption
                                              .copyWith(
                                            color: AppColors.of(context)
                                                .textTertiary,
                                            fontSize: 8,
                                          ),
                                        ),
                                      if (isCurrent)
                                        Text(
                                          'detay ›',
                                          style: AppTypography.caption
                                              .copyWith(
                                            color: AppColors.of(context)
                                                .brandPrimary,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Divider(height: _dividerH),
                                // Gelir (row 0 — no shading)
                                DataTableCellValue(
                                  value: s.totalIncome,
                                  color: AppColors.of(context).income,
                                  height: _rowH,
                                ),
                                // Gider (row 1 — alternating shading)
                                Container(
                                  color: AppColors.of(context)
                                      .surfaceOverlay
                                      .withValues(alpha: 0.3),
                                  child: DataTableCellValue(
                                    value: s.totalExpense,
                                    color: AppColors.of(context).expense,
                                    height: _rowH,
                                  ),
                                ),
                                // Birikim (row 2 — no shading)
                                if (widget.includeSavings)
                                  DataTableCellValue(
                                    value: s.totalSavings,
                                    color: AppColors.of(context).savings,
                                    height: _rowH,
                                  ),
                                const Divider(height: _dividerH),
                                // Aylık Net — vurgulu
                                Container(
                                  decoration: BoxDecoration(
                                    color: (displayNet >= 0
                                            ? AppColors.of(context).income
                                            : AppColors.of(context).expense)
                                        .withValues(alpha: 0.04),
                                  ),
                                  child: DataTableCellValue(
                                    value: displayNet,
                                    color: displayNet >= 0
                                        ? AppColors.of(context).income
                                        : AppColors.of(context).expense,
                                    height: _netH,
                                    bold: true,
                                  ),
                                ),
                                // Kümülatif — bold + green + goal marker
                                DataTableCumulativeCell(
                                  value: s.netWithCarryOver,
                                  height: _cumH,
                                  goalTarget: widget.nearestGoalTarget,
                                ),
                              ],
                            ),
                          ),
                        );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Left label cell
class FlowLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double height;
  final bool bold;

  const FlowLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.height,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: 11,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class FlowRowConfig {
  final String label;
  final IconData icon;
  final Color color;
  const FlowRowConfig(this.label, this.icon, this.color);
}
