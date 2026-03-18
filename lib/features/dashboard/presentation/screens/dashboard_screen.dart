import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/domain/models/month_summary.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/shared/widgets/data_table_cells.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _months = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static String monthLabel(String yearMonth) {
    final parts = yearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    return '${_months[month]} $year';
  }

  static String shortMonthLabel(String yearMonth) {
    final parts = yearMonth.split('-');
    final month = int.parse(parts[1]);
    final name = _months[month];
    final short = name.length > 3 ? name.substring(0, 3) : name;
    return '$short \'${parts[0].substring(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allIncomesAsync = ref.watch(allIncomesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final allSavingsAsync = ref.watch(allSavingsProvider);

    final isLoading = allIncomesAsync.isLoading ||
        allExpensesAsync.isLoading ||
        allSavingsAsync.isLoading;

    final summaries = ref.watch(allMonthSummariesProvider);
    final projections = ref.watch(futureProjectionsProvider);
    final includeSavings = ref.watch(includeSavingsInProjectionProvider);
    final totalSavings = ref.watch(totalSavingsAmountProvider);

    final cumulativeNet =
        summaries.isNotEmpty ? summaries.first.netWithCarryOver : 0.0;
    final overallHealth =
        summaries.isNotEmpty ? summaries.first.healthScore : 0;
    final currentMonth = summaries.isNotEmpty ? summaries.first : null;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surfaceBackground,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                    ),
                    borderRadius: AppRadius.chip,
                  ),
                  child: const Icon(LucideIcons.wallet,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Savvy',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.brandPrimary,
                  ),
                ),
              ],
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: isLoading
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.base),
                      const SavvyShimmer(
                        child: Column(
                          children: [
                            ShimmerBox(height: 170),
                            SizedBox(height: AppSpacing.base),
                            ShimmerBox(height: 80),
                            SizedBox(height: AppSpacing.base),
                            ShimmerBox(height: 60),
                            SizedBox(height: AppSpacing.sm),
                            ShimmerBox(height: 160),
                          ],
                        ),
                      ),
                    ]),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),

                      // 1) Hero Card
                      _HeroCard(
                        cumulativeNet: cumulativeNet,
                        healthScore: overallHealth,
                      ),

                      const SizedBox(height: AppSpacing.base),

                      // 2) Quick Stats
                      if (currentMonth != null) ...[
                        _QuickStatsRow(summary: currentMonth),
                        const SizedBox(height: AppSpacing.base),
                      ],

                      // 3) Birikim toggle
                      if (totalSavings > 0) ...[
                        _SavingsToggle(
                          isEnabled: includeSavings,
                          totalSavings: totalSavings,
                          onToggle: () {
                            HapticFeedback.selectionClick();
                            ref
                                .read(
                                    includeSavingsInProjectionProvider.notifier)
                                .toggle();
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // 4) Aylık Akış tablosu
                      _MonthlyFlowTable(
                        summaries: summaries,
                        projections: projections,
                        includeSavings: includeSavings,
                        onMonthTap: (ym) {
                          HapticFeedback.lightImpact();
                          context.go('/dashboard/month/$ym');
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // 5) Trend grafiği
                      if (projections.isNotEmpty)
                        _TrendChart(projections: projections),

                      const SizedBox(height: 100),
                    ]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Card ───────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final double cumulativeNet;
  final int healthScore;

  const _HeroCard({
    required this.cumulativeNet,
    required this.healthScore,
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
    final label = FinancialCalculator.healthScoreLabel(healthScore);
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
                'TOPLAM BAKIYE',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textInverse.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textInverse.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HealthIcon(score: healthScore, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$label · $healthScore',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textInverse,
                      ),
                    ),
                  ],
                ),
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

// ─── Quick Stats Row ─────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final MonthSummary summary;
  const _QuickStatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            label: 'Gelir',
            amount: summary.totalIncome,
            color: AppColors.income,
            icon: AppIcons.income,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickStatCard(
            label: 'Gider',
            amount: summary.totalExpense,
            color: AppColors.expense,
            icon: AppIcons.expense,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _QuickStatCard(
            label: 'Birikim',
            amount: summary.totalSavings,
            color: AppColors.savings,
            icon: AppIcons.savings,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _QuickStatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.input,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.formatNoDecimal(amount),
              style: AppTypography.numericSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Savings Toggle ──────────────────────────────────────────────────────────

class _SavingsToggle extends StatelessWidget {
  final bool isEnabled;
  final double totalSavings;
  final VoidCallback onToggle;

  const _SavingsToggle({
    required this.isEnabled,
    required this.totalSavings,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: AppCurve.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.savings.withValues(alpha: 0.08)
              : AppColors.surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isEnabled
                ? AppColors.savings.withValues(alpha: 0.4)
                : AppColors.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.piggyBank, size: 20, color: AppColors.savings),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birikimi Dahil Et',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${CurrencyFormatter.formatNoDecimal(totalSavings)} gelir olarak ekle',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Custom toggle
            AnimatedContainer(
              duration: AppDuration.fast,
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.savings : AppColors.surfaceOverlay,
                borderRadius: AppRadius.pill,
              ),
              child: AnimatedAlign(
                duration: AppDuration.fast,
                curve: AppCurve.standard,
                alignment:
                    isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Monthly Flow Table (Excel-like) ─────────────────────────────────────────

class _MonthlyFlowTable extends StatefulWidget {
  final List<MonthSummary> summaries;
  final List<MonthSummary> projections;
  final bool includeSavings;
  final void Function(String yearMonth) onMonthTap;

  const _MonthlyFlowTable({
    required this.summaries,
    required this.projections,
    required this.includeSavings,
    required this.onMonthTap,
  });

  @override
  State<_MonthlyFlowTable> createState() => _MonthlyFlowTableState();
}

class _MonthlyFlowTableState extends State<_MonthlyFlowTable> {
  late ScrollController _scrollController;
  bool _collapsed = false;

  static const _colW = 72.0;
  static const _labelW = 64.0;
  static const _labelCollapsedW = 36.0;
  static const _headerH = 40.0;
  static const _rowH = 34.0;
  static const _netH = 36.0;
  static const _cumH = 40.0;
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

    final rows = <_FlowRowConfig>[
      const _FlowRowConfig('Gelir', AppIcons.income, AppColors.income),
      const _FlowRowConfig('Gider', AppIcons.expense, AppColors.expense),
      if (widget.includeSavings)
        const _FlowRowConfig('Birikim', AppIcons.savings, AppColors.savings),
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
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceOverlay,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                '${pastSorted.length} geçmiş · ${widget.projections.length} tahmini',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ),
            const Spacer(),
            Icon(Icons.swipe_rounded, size: 14, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              'Kaydır',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
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
                    ...rows.map((r) => _FlowLabel(
                          collapsed: _collapsed,
                          icon: r.icon,
                          label: r.label,
                          color: r.color,
                          height: _rowH,
                        )),
                    const Divider(height: _dividerH),
                    _FlowLabel(
                      collapsed: _collapsed,
                      icon: AppIcons.balance,
                      label: 'Aylık Net',
                      color: AppColors.textPrimary,
                      height: _netH,
                      bold: true,
                    ),
                    _FlowLabel(
                      collapsed: _collapsed,
                      icon: AppIcons.networth,
                      label: 'Kümülatif',
                      color: AppColors.brandPrimary,
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
                                ? AppColors.brandPrimary
                                    .withValues(alpha: 0.05)
                                : !isPast
                                    ? AppColors.surfaceOverlay
                                        .withValues(alpha: 0.4)
                                    : Colors.transparent,
                            borderRadius: AppRadius.input,
                            border: isCurrent
                                ? Border.all(
                                    color: AppColors.brandPrimary
                                        .withValues(alpha: 0.25),
                                    width: 1.5,
                                  )
                                : null,
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
                                      DashboardScreen.shortMonthLabel(
                                          s.yearMonth),
                                      style:
                                          AppTypography.labelSmall.copyWith(
                                        color: isCurrent
                                            ? AppColors.brandPrimary
                                            : isPast
                                                ? AppColors.textPrimary
                                                : AppColors.textTertiary,
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
                                          color: AppColors.textTertiary,
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
                                color: AppColors.income,
                                height: _rowH,
                                prefix: '+',
                              ),
                              // Gider
                              DataTableCellValue(
                                value: s.totalExpense,
                                color: AppColors.expense,
                                height: _rowH,
                                prefix: '-',
                              ),
                              // Birikim (conditional)
                              if (widget.includeSavings)
                                DataTableCellValue(
                                  value: s.totalSavings,
                                  color: AppColors.savings,
                                  height: _rowH,
                                ),
                              const Divider(height: _dividerH),
                              // Aylık Net
                              DataTableCellValue(
                                value: displayNet,
                                color: displayNet >= 0
                                    ? AppColors.income
                                    : AppColors.expense,
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
class _FlowLabel extends StatelessWidget {
  final bool collapsed;
  final IconData icon;
  final String label;
  final Color color;
  final double height;
  final bool bold;

  const _FlowLabel({
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

class _FlowRowConfig {
  final String label;
  final IconData icon;
  final Color color;
  const _FlowRowConfig(this.label, this.icon, this.color);
}

// ─── Trend Chart ─────────────────────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  final List<MonthSummary> projections;

  const _TrendChart({required this.projections});

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
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '12 ay',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
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
                                    ? AppColors.income
                                    : AppColors.expense,
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
                                      AppColors.income
                                          .withValues(alpha: 0.4),
                                      AppColors.income,
                                    ]
                                  : [
                                      AppColors.expense
                                          .withValues(alpha: 0.4),
                                      AppColors.expense,
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
                          DashboardScreen.shortMonthLabel(p.yearMonth)
                              .split(' ')[0],
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
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

// ─── Health Icon ─────────────────────────────────────────────────────────────

class _HealthIcon extends StatelessWidget {
  final int score;
  final double size;
  const _HealthIcon({required this.score, required this.size});

  @override
  Widget build(BuildContext context) {
    final icon = switch (score) {
      >= 80 => Icons.rocket_launch_rounded,
      >= 65 => Icons.trending_up_rounded,
      >= 50 => Icons.horizontal_rule_rounded,
      >= 35 => Icons.trending_down_rounded,
      _ => Icons.warning_rounded,
    };
    final color = switch (score) {
      >= 80 => AppColors.income,
      >= 65 => AppColors.brandPrimary,
      >= 50 => AppColors.warning,
      >= 35 => AppColors.savings,
      _ => AppColors.expense,
    };
    return Icon(icon, size: size, color: color);
  }
}
