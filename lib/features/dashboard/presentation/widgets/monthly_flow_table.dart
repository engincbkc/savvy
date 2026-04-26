import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/shared/widgets/data_table_cells.dart';
import 'package:savvy/shared/widgets/info_tooltip.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart' show simulationMonthlyPayment, simulationMonthlyIncome, simulationMaxTermMonths;

/// Dahil edilen simülasyonların satır bilgisi
class SimFlowRow {
  final String label;
  final double monthlyExpense;
  final double monthlyIncome;
  final int? termMonths;

  const SimFlowRow({
    required this.label,
    required this.monthlyExpense,
    required this.monthlyIncome,
    this.termMonths,
  });
}

class MonthlyFlowTable extends StatefulWidget {
  final List<MonthSummary> summaries;
  final List<MonthSummary> projections;
  final bool includeSavings;
  final void Function(String yearMonth) onMonthTap;
  final double? nearestGoalTarget;
  final bool showDetailHint;
  final List<SimulationEntry> includedSimulations;

  const MonthlyFlowTable({
    super.key,
    required this.summaries,
    required this.projections,
    required this.includeSavings,
    required this.onMonthTap,
    this.nearestGoalTarget,
    this.showDetailHint = true,
    this.includedSimulations = const [],
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

  void _showColumnFocus(int index, MonthSummary month, bool isPast) {
    HapticFeedback.lightImpact();
    final pastSorted = widget.summaries.reversed.toList();
    final isCurrent = isPast && index == pastSorted.length - 1;

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        pageBuilder: (context, anim, _) {
          return _FullScreenColumnZoom(
            month: month,
            isPast: isPast,
            isCurrent: isCurrent,
            includeSavings: widget.includeSavings,
            animation: anim,
            onDetailTap: isPast
                ? () {
                    Navigator.pop(context);
                    widget.onMonthTap(month.yearMonth);
                  }
                : null,
          );
        },
        transitionsBuilder: (context, anim, _, child) => child,
      ),
    );
  }

  void _openFullScreenModal(
      BuildContext context, List<MonthSummary> pastSorted) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, anim, _) {
          return MonthlyFlowDetailModal(
            pastSorted: pastSorted,
            projections: widget.projections,
            includeSavings: widget.includeSavings,
            nearestGoalTarget: widget.nearestGoalTarget,
            onMonthTap: widget.showDetailHint ? widget.onMonthTap : null,
            animation: anim,
          );
        },
        transitionsBuilder: (context, anim, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  String _simEmoji(SimulationEntry sim) {
    final name = sim.template?.name ?? sim.type?.name ?? '';
    return switch (name) {
      'housing' => '🏠',
      'car' => '🚗',
      'credit' => '💳',
      'rentChange' => '🏠',
      'salaryChange' => '💼',
      'investment' => '📈',
      _ => '⚡',
    };
  }

  @override
  Widget build(BuildContext context) {
    final pastSorted = widget.summaries.reversed.toList();
    final allMonths = [...pastSorted, ...widget.projections];
    if (allMonths.isEmpty) return const SizedBox.shrink();

    // Dahil edilen simülasyonların satır bilgilerini hazırla
    final simRows = <SimFlowRow>[];
    for (final sim in widget.includedSimulations) {
      simRows.add(SimFlowRow(
        label: sim.title,
        monthlyExpense: simulationMonthlyPayment(sim),
        monthlyIncome: simulationMonthlyIncome(sim),
        termMonths: simulationMaxTermMonths(sim),
      ));
    }

    final rows = <FlowRowConfig>[
      FlowRowConfig('Gelir', AppIcons.income, AppColors.of(context).income),
      FlowRowConfig('Gider', AppIcons.expense, AppColors.of(context).expense),
      if (widget.includeSavings)
        FlowRowConfig(
            'Birikim', AppIcons.savings, AppColors.of(context).savings),
      // Simülasyon satırları
      for (final sim in widget.includedSimulations)
        FlowRowConfig(
          '${_simEmoji(sim)} ${sim.title}',
          sim.template?.icon ?? sim.type?.icon ?? Icons.auto_awesome,
          sim.template?.color ?? sim.type?.color ?? AppColors.of(context).brandPrimary,
        ),
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
            const SizedBox(width: AppSpacing.md),
            GestureDetector(
              onTap: () => _openFullScreenModal(context, pastSorted),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.of(context)
                      .brandPrimary
                      .withValues(alpha: 0.08),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  Icons.open_in_full_rounded,
                  size: 14,
                  color: AppColors.of(context).brandPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Table with focus overlay
        Stack(
          children: [
            // Actual table
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
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.of(context)
                                .brandPrimary
                                .withValues(alpha: 0.03),
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
                          final displayNet =
                              s.totalIncome - s.totalExpense;

                          return GestureDetector(
                            onTap: () =>
                                _showColumnFocus(idx, s, isPast),
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
                                  _buildColHeader(
                                      s, isPast, isCurrent),
                                  const Divider(height: _dividerH),
                                  DataTableCellValue(
                                    value: s.totalIncome,
                                    color:
                                        AppColors.of(context).income,
                                    height: _rowH,
                                  ),
                                  Container(
                                    color: AppColors.of(context)
                                        .surfaceOverlay
                                        .withValues(alpha: 0.3),
                                    child: DataTableCellValue(
                                      value: s.totalExpense,
                                      color: AppColors.of(context)
                                          .expense,
                                      height: _rowH,
                                    ),
                                  ),
                                  if (widget.includeSavings)
                                    DataTableCellValue(
                                      value: s.totalSavings,
                                      color: AppColors.of(context)
                                          .savings,
                                      height: _rowH,
                                    ),
                                  // Simülasyon satırları
                                  ...simRows.map((sr) {
                                    // Geçmiş aylarda simülasyon etkisi gösterme
                                    if (isPast) {
                                      return DataTableCellValue(
                                        value: 0,
                                        color: AppColors.of(context).brandPrimary,
                                        height: _rowH,
                                      );
                                    }
                                    // Tahmini aylarda: term süresi kontrolü
                                    final now = DateTime.now();
                                    final monthsFromNow = (s.yearMonth != '')
                                        ? (() {
                                            final parts = s.yearMonth.split('-');
                                            if (parts.length != 2) return 0;
                                            final y = int.tryParse(parts[0]) ?? now.year;
                                            final m = int.tryParse(parts[1]) ?? now.month;
                                            return (y - now.year) * 12 + m - now.month;
                                          })()
                                        : 0;
                                    if (sr.termMonths != null && monthsFromNow > sr.termMonths!) {
                                      return DataTableCellValue(
                                        value: 0,
                                        color: AppColors.of(context).brandPrimary,
                                        height: _rowH,
                                      );
                                    }
                                    // Net etki = gelir - gider (negatifse gider ağırlıklı)
                                    final netImpact = sr.monthlyIncome - sr.monthlyExpense;
                                    return Container(
                                      color: AppColors.of(context).brandPrimary.withValues(alpha: 0.04),
                                      child: DataTableCellValue(
                                        value: netImpact,
                                        color: netImpact >= 0
                                            ? AppColors.of(context).income
                                            : AppColors.of(context).expense,
                                        height: _rowH,
                                      ),
                                    );
                                  }),
                                  const Divider(height: _dividerH),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: (displayNet >= 0
                                              ? AppColors.of(context)
                                                  .income
                                              : AppColors.of(context)
                                                  .expense)
                                          .withValues(alpha: 0.04),
                                    ),
                                    child: DataTableCellValue(
                                      value: displayNet,
                                      color: displayNet >= 0
                                          ? AppColors.of(context)
                                              .income
                                          : AppColors.of(context)
                                              .expense,
                                      height: _netH,
                                      bold: true,
                                    ),
                                  ),
                                  DataTableCumulativeCell(
                                    value: s.netWithCarryOver,
                                    height: _cumH,
                                    goalTarget:
                                        widget.nearestGoalTarget,
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
        ),
      ],
    );
  }

  Widget _buildColHeader(MonthSummary s, bool isPast, bool isCurrent) {
    return SizedBox(
      height: _headerH,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                MonthLabels.short(s.yearMonth),
                style: AppTypography.labelSmall.copyWith(
                  color: isCurrent
                      ? AppColors.of(context).brandPrimary
                      : isPast
                          ? AppColors.of(context).textPrimary
                          : AppColors.of(context).textTertiary,
                  fontWeight:
                      isCurrent ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11,
                  decoration: isPast && !isCurrent
                      ? TextDecoration.underline
                      : null,
                  decorationColor: AppColors.of(context)
                      .textTertiary
                      .withValues(alpha: 0.4),
                  decorationStyle: TextDecorationStyle.dotted,
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
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textTertiary,
                fontSize: 8,
              ),
            ),
        ],
      ),
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

/// Fullscreen blurred overlay showing a zoomed column strip.
class _FullScreenColumnZoom extends StatelessWidget {
  final MonthSummary month;
  final bool isPast;
  final bool isCurrent;
  final bool includeSavings;
  final Animation<double> animation;
  final VoidCallback? onDetailTap;

  const _FullScreenColumnZoom({
    required this.month,
    required this.isPast,
    required this.isCurrent,
    required this.includeSavings,
    required this.animation,
    this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final displayNet = month.totalIncome - month.totalExpense;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.pop(context),
          child: Stack(
            children: [
              // Blurred background
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8 * t,
                  sigmaY: 8 * t,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35 * t),
                ),
              ),

              // Zoomed column card — centered, full height
              Center(
                child: Opacity(
                  opacity: t,
                  child: Transform.scale(
                    scale: 0.85 + 0.15 * t,
                    child: GestureDetector(
                      onTap: () {}, // Prevent dismiss
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                          horizontal: AppSpacing.base,
                        ),
                        decoration: BoxDecoration(
                          color: c.surfaceCard,
                          borderRadius: AppRadius.cardLg,
                          border: isCurrent
                              ? Border.all(
                                  color: c.brandPrimary
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.15),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Month header
                            Text(
                              MonthLabels.short(month.yearMonth),
                              style:
                                  AppTypography.headlineMedium.copyWith(
                                color: isCurrent
                                    ? c.brandPrimary
                                    : c.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                width: 24,
                                height: 3,
                                margin:
                                    const EdgeInsets.only(top: 4),
                                decoration: BoxDecoration(
                                  color: c.brandPrimary,
                                  borderRadius: AppRadius.pill,
                                ),
                              ),
                            if (!isPast)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 2),
                                child: Text(
                                  'tahmini',
                                  style:
                                      AppTypography.caption.copyWith(
                                    color: c.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.xl),

                            // Gelir
                            _ZoomCell(
                              label: 'Gelir',
                              value: month.totalIncome,
                              color: c.income,
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Gider
                            _ZoomCell(
                              label: 'Gider',
                              value: month.totalExpense,
                              color: c.expense,
                            ),

                            if (includeSavings) ...[
                              const SizedBox(height: AppSpacing.lg),
                              _ZoomCell(
                                label: 'Birikim',
                                value: month.totalSavings,
                                color: c.savings,
                              ),
                            ],

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md),
                              child: Divider(
                                color: c.borderDefault
                                    .withValues(alpha: 0.3),
                                height: 1,
                              ),
                            ),

                            // Net
                            _ZoomCell(
                              label: 'Net',
                              value: displayNet,
                              color: displayNet >= 0
                                  ? c.income
                                  : c.expense,
                              bold: true,
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Kümülatif
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                                horizontal: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: (month.netWithCarryOver >= 0
                                        ? c.income
                                        : c.expense)
                                    .withValues(alpha: 0.06),
                                borderRadius: AppRadius.chip,
                              ),
                              child: _ZoomCell(
                                label: 'Kümülatif',
                                value: month.netWithCarryOver,
                                color: month.netWithCarryOver >= 0
                                    ? c.income
                                    : c.expense,
                                bold: true,
                                large: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Full-Screen Modal Table ─────────────────────────────────
class MonthlyFlowDetailModal extends StatefulWidget {
  final List<MonthSummary> pastSorted;
  final List<MonthSummary> projections;
  final bool includeSavings;
  final double? nearestGoalTarget;
  final void Function(String yearMonth)? onMonthTap;
  final Animation<double> animation;

  const MonthlyFlowDetailModal({
    super.key,
    required this.pastSorted,
    required this.projections,
    required this.includeSavings,
    this.nearestGoalTarget,
    this.onMonthTap,
    required this.animation,
  });

  @override
  State<MonthlyFlowDetailModal> createState() =>
      _MonthlyFlowDetailModalState();
}

class _MonthlyFlowDetailModalState extends State<MonthlyFlowDetailModal> {
  late ScrollController _hScrollCtrl;

  static const _colW = 100.0; // wider columns in modal
  static const _labelW = 80.0; // wider labels in modal
  static const _headerH = 44.0;
  static const _rowH = 52.0;
  static const _netH = 52.0;
  static const _cumH = 52.0;
  static const _dividerH = 1.0;

  @override
  void initState() {
    super.initState();
    final pastLen = widget.pastSorted.length;
    final initialOffset = pastLen > 3 ? (pastLen - 3) * _colW : 0.0;
    _hScrollCtrl = ScrollController(initialScrollOffset: initialOffset);
    // Allow landscape in modal
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Lock back to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _hScrollCtrl.dispose();
    super.dispose();
  }

  void _showColumnFocus(
      BuildContext context, MonthSummary month, bool isPast, bool isCurrent) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (ctx, anim, _) {
          return _FullScreenColumnZoom(
            month: month,
            isPast: isPast,
            isCurrent: isCurrent,
            includeSavings: widget.includeSavings,
            animation: anim,
            onDetailTap: isPast && widget.onMonthTap != null
                ? () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    widget.onMonthTap!(month.yearMonth);
                  }
                : null,
          );
        },
        transitionsBuilder: (ctx, anim, _, child) => child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final allMonths = [...widget.pastSorted, ...widget.projections];
    final pastLen = widget.pastSorted.length;

    final rows = <FlowRowConfig>[
      FlowRowConfig('Gelir', AppIcons.income, c.income),
      FlowRowConfig('Gider', AppIcons.expense, c.expense),
      if (widget.includeSavings)
        FlowRowConfig('Birikim', AppIcons.savings, c.savings),
    ];

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      appBar: AppBar(
        backgroundColor: c.surfaceBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aylık Akış Detayı',
              style: AppTypography.headlineSmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$pastLen geçmiş · ${widget.projections.length} tahmini',
              style: AppTypography.caption.copyWith(
                color: c.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.surfaceOverlay,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded, size: 18, color: c.textSecondary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // ── Sticky left labels ──
              Container(
                width: _labelW,
                decoration: BoxDecoration(
                  color: c.surfaceBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header spacer
                    SizedBox(height: _headerH),
                    Divider(height: _dividerH, color: c.borderDefault.withValues(alpha: 0.3)),
                    // Row labels
                    ...rows.asMap().entries.map((e) {
                      final r = e.value;
                      final isOdd = e.key.isOdd;
                      final child = _ModalLabel(
                        label: r.label,
                        color: r.color,
                        height: _rowH,
                      );
                      if (isOdd) {
                        return Container(
                          color: c.surfaceOverlay.withValues(alpha: 0.3),
                          child: child,
                        );
                      }
                      return child;
                    }),
                    Divider(height: _dividerH, color: c.borderDefault.withValues(alpha: 0.3)),
                    // Net label
                    Container(
                      color: c.brandPrimary.withValues(alpha: 0.03),
                      child: _ModalLabel(
                        label: 'Net',
                        color: c.textPrimary,
                        height: _netH,
                        bold: true,
                      ),
                    ),
                    // Cumulative label
                    _ModalLabel(
                      label: 'Kümülatif',
                      color: c.income,
                      height: _cumH,
                      bold: true,
                    ),
                  ],
                ),
              ),

              // ── Scrollable columns ──
              Expanded(
                child: SingleChildScrollView(
                  controller: _hScrollCtrl,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: allMonths.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final s = entry.value;
                      final isPast = idx < pastLen;
                      final isCurrent = isPast && idx == pastLen - 1;
                      final displayNet = s.totalIncome - s.totalExpense;

                      return GestureDetector(
                        onTap: () =>
                            _showColumnFocus(context, s, isPast, isCurrent),
                        child: Container(
                          width: _colW,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? c.brandPrimary.withValues(alpha: 0.06)
                                : !isPast
                                    ? c.surfaceOverlay.withValues(alpha: 0.3)
                                    : Colors.transparent,
                            borderRadius: AppRadius.input,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              _ModalColHeader(
                                yearMonth: s.yearMonth,
                                isPast: isPast,
                                isCurrent: isCurrent,
                              ),
                              Divider(
                                  height: _dividerH,
                                  color: c.borderDefault
                                      .withValues(alpha: 0.3)),
                              // Income
                              DataTableCellValue(
                                value: s.totalIncome,
                                color: c.income,
                                height: _rowH,
                              ),
                              // Expense
                              Container(
                                color: c.surfaceOverlay
                                    .withValues(alpha: 0.3),
                                child: DataTableCellValue(
                                  value: s.totalExpense,
                                  color: c.expense,
                                  height: _rowH,
                                ),
                              ),
                              // Savings
                              if (widget.includeSavings)
                                DataTableCellValue(
                                  value: s.totalSavings,
                                  color: c.savings,
                                  height: _rowH,
                                ),
                              Divider(
                                  height: _dividerH,
                                  color: c.borderDefault
                                      .withValues(alpha: 0.3)),
                              // Net
                              Container(
                                decoration: BoxDecoration(
                                  color: (displayNet >= 0
                                          ? c.income
                                          : c.expense)
                                      .withValues(alpha: 0.04),
                                ),
                                child: DataTableCellValue(
                                  value: displayNet,
                                  color: displayNet >= 0
                                      ? c.income
                                      : c.expense,
                                  height: _netH,
                                  bold: true,
                                ),
                              ),
                              // Cumulative
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
        ),
      ),
    );
  }
}

class _ModalLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double height;
  final bool bold;

  const _ModalLabel({
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
          style: AppTypography.titleSmall.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ModalColHeader extends StatelessWidget {
  final String yearMonth;
  final bool isPast;
  final bool isCurrent;

  const _ModalColHeader({
    required this.yearMonth,
    required this.isPast,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      height: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            MonthLabels.short(yearMonth),
            style: AppTypography.labelMedium.copyWith(
              color: isCurrent
                  ? c.brandPrimary
                  : isPast
                      ? c.textPrimary
                      : c.textTertiary,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          if (isCurrent)
            Container(
              width: 20,
              height: 2,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: c.brandPrimary,
                borderRadius: AppRadius.pill,
              ),
            ),
          if (!isPast)
            Text(
              'tahmini',
              style: AppTypography.caption.copyWith(
                color: c.textTertiary,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomCell extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;
  final bool large;

  const _ZoomCell({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: color.withValues(alpha: 0.6),
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            CurrencyFormatter.formatNoDecimal(value),
            style: (large
                    ? AppTypography.numericLarge
                    : AppTypography.numericMedium)
                .copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
