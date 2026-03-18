import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/shared/widgets/data_table_cells.dart';

class MonthlyFlowTable extends StatefulWidget {
  final List<MonthSummary> summaries;
  final List<MonthSummary> projections;
  final bool includeSavings;
  final void Function(String yearMonth) onMonthTap;

  const MonthlyFlowTable({
    super.key,
    required this.summaries,
    required this.projections,
    required this.includeSavings,
    required this.onMonthTap,
  });

  @override
  State<MonthlyFlowTable> createState() => _MonthlyFlowTableState();
}

class _MonthlyFlowTableState extends State<MonthlyFlowTable> {
  late ScrollController _scrollController;
  bool _collapsed = false;

  static const _colW = 72.0;
  static const _labelW = 64.0;
  static const _labelCollapsedW = 36.0;
  static const _headerH = 40.0;
  static const _rowH = 34.0;
  static const _netH = 36.0;
  static const _cumH = 44.0;
  static const _dividerH = 1.0;

  @override
  void initState() {
    super.initState();
    final pastLen = widget.summaries.length;
    final initialOffset = pastLen > 3 ? (pastLen - 3) * _colW : 0.0;
    _collapsed = initialOffset > 20;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final shouldCollapse = _scrollController.offset > 20;
    if (_collapsed != shouldCollapse) {
      setState(() => _collapsed = shouldCollapse);
    }
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
        FlowRowConfig('Birikim', AppIcons.savings, AppColors.of(context).savings),
    ];

    final totalH =
        _headerH + _dividerH + (rows.length * _rowH) + _dividerH + _netH + _cumH;
    final labelW = _collapsed ? _labelCollapsedW : _labelW;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
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
            Icon(Icons.swipe_rounded, size: 14, color: AppColors.of(context).textTertiary),
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
              // Left labels (animated width — collapses to icons on scroll)
              AnimatedContainer(
                duration: AppDuration.fast,
                curve: AppCurve.standard,
                width: labelW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: _headerH),
                    const Divider(height: _dividerH),
                    ...rows.map((r) => FlowLabel(
                          collapsed: _collapsed,
                          icon: r.icon,
                          label: r.label,
                          color: r.color,
                          height: _rowH,
                        )),
                    const Divider(height: _dividerH),
                    FlowLabel(
                      collapsed: _collapsed,
                      icon: AppIcons.balance,
                      label: 'Aylık Net',
                      color: AppColors.of(context).textPrimary,
                      height: _netH,
                      bold: true,
                    ),
                    FlowLabel(
                      collapsed: _collapsed,
                      icon: AppIcons.networth,
                      label: 'Kümülatif',
                      color: AppColors.of(context).brandPrimary,
                      height: _cumH,
                      bold: true,
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
                      final isCurrent = isPast && idx == pastSorted.length - 1;
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
                                ? AppColors.of(context).brandPrimary
                                    .withValues(alpha: 0.05)
                                : !isPast
                                    ? AppColors.of(context).surfaceOverlay
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      MonthLabels.short(
                                          s.yearMonth),
                                      style:
                                          AppTypography.labelSmall.copyWith(
                                        color: isCurrent
                                            ? AppColors.of(context).brandPrimary
                                            : isPast
                                                ? AppColors.of(context).textPrimary
                                                : AppColors.of(context).textTertiary,
                                        fontWeight: isCurrent
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (!isPast)
                                      Text(
                                        'tahmini',
                                        style:
                                            AppTypography.caption.copyWith(
                                          color: AppColors.of(context).textTertiary,
                                          fontSize: 8,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Divider(height: _dividerH),
                              // Gelir
                              DataTableCellValue(
                                value: s.totalIncome,
                                color: AppColors.of(context).income,
                                height: _rowH,
                                prefix: '+',
                              ),
                              // Gider
                              DataTableCellValue(
                                value: s.totalExpense,
                                color: AppColors.of(context).expense,
                                height: _rowH,
                                prefix: '-',
                              ),
                              // Birikim (conditional)
                              if (widget.includeSavings)
                                DataTableCellValue(
                                  value: s.totalSavings,
                                  color: AppColors.of(context).savings,
                                  height: _rowH,
                                ),
                              const Divider(height: _dividerH),
                              // Aylık Net
                              DataTableCellValue(
                                value: displayNet,
                                color: displayNet >= 0
                                    ? AppColors.of(context).income
                                    : AppColors.of(context).expense,
                                height: _netH,
                                bold: true,
                              ),
                              // Kümülatif
                              DataTableCumulativeCell(
                                value: s.netWithCarryOver,
                                height: _cumH,
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

// Left label cell — shows text when expanded, icon when collapsed
class FlowLabel extends StatelessWidget {
  final bool collapsed;
  final IconData icon;
  final String label;
  final Color color;
  final double height;
  final bool bold;

  const FlowLabel({
    super.key,
    required this.collapsed,
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
      child: AnimatedSwitcher(
        duration: AppDuration.fast,
        child: collapsed
            ? Tooltip(
                key: const ValueKey('icon'),
                message: label,
                child: Center(
                  child: Icon(icon, size: 14, color: color),
                ),
              )
            : Align(
                key: const ValueKey('text'),
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
