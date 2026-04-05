import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/domain/simulation_calculator.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class SimulationCompareScreen extends ConsumerStatefulWidget {
  const SimulationCompareScreen({super.key});

  @override
  ConsumerState<SimulationCompareScreen> createState() =>
      _SimulationCompareScreenState();
}

class _SimulationCompareScreenState
    extends ConsumerState<SimulationCompareScreen> {
  SimulationEntry? _scenarioA;
  SimulationEntry? _scenarioB;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final simsAsync = ref.watch(allSimulationsProvider);

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      appBar: AppBar(
        backgroundColor: c.surfaceBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: c.textPrimary, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Karşılaştır',
          style: AppTypography.headlineSmall.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: simsAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => _buildError(c, e),
        data: (sims) {
          final available = sims.where((s) => !s.isDeleted).toList();
          return _buildContent(c, available);
        },
      ),
    );
  }

  Widget _buildContent(dynamic c, List<SimulationEntry> sims) {
    final colors = AppColors.of(context);

    // Compute results when both selected
    SimulationResult? resultA;
    SimulationResult? resultB;

    if (_scenarioA != null && _scenarioB != null) {
      final summaries = ref.watch(allMonthSummariesProvider);
      final budget = summaries.isNotEmpty ? summaries.first : null;
      if (budget != null) {
        final baseItems = ref.watch(projectionBaseItemsProvider);
        resultA = SimulationCalculator.calculateScenario(
          changes: _scenarioA!.changes,
          currentBudget: budget,
          baseItems: baseItems,
        );
        resultB = SimulationCalculator.calculateScenario(
          changes: _scenarioB!.changes,
          currentBudget: budget,
          baseItems: baseItems,
        );
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Picker row ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ScenarioPicker(
                  label: 'Senaryo A',
                  selected: _scenarioA,
                  all: sims,
                  exclude: _scenarioB,
                  accentColor: colors.brandPrimary,
                  onChanged: (sim) {
                    HapticFeedback.selectionClick();
                    setState(() => _scenarioA = sim);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Icon(
                  LucideIcons.gitCompare,
                  size: 20,
                  color: colors.textTertiary,
                ),
              ),
              Expanded(
                child: _ScenarioPicker(
                  label: 'Senaryo B',
                  selected: _scenarioB,
                  all: sims,
                  exclude: _scenarioA,
                  accentColor: const Color(0xFF8B5CF6),
                  onChanged: (sim) {
                    HapticFeedback.selectionClick();
                    setState(() => _scenarioB = sim);
                  },
                ),
              ),
            ],
          ),

          // ── Empty state when no selection ────────────────────────────
          if (_scenarioA == null || _scenarioB == null) ...[
            const SizedBox(height: AppSpacing.xl2),
            _buildPickerHint(colors),
          ],

          // ── Comparison results ───────────────────────────────────────
          if (resultA != null && resultB != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _ComparisonTable(
              simA: _scenarioA!,
              simB: _scenarioB!,
              resultA: resultA,
              resultB: resultB,
            ),
            const SizedBox(height: AppSpacing.xl),
            _ProjectionTable(
              simA: _scenarioA!,
              simB: _scenarioB!,
              resultA: resultA,
              resultB: resultB,
            ),
            const SizedBox(height: AppSpacing.xl3),
          ],
        ],
      ),
    );
  }

  Widget _buildPickerHint(dynamic colors) {
    final c = AppColors.of(context);
    return Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.surfaceOverlay,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.gitCompare,
              size: 30,
              color: c.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'İki senaryo seçin',
            style: AppTypography.titleMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Senaryo A ve B\'yi seçerek\nmetriklerini yan yana karşılaştırın',
            style: AppTypography.bodySmall.copyWith(color: c.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildError(dynamic c, Object error) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertCircle, size: 40, color: colors.expense),
          const SizedBox(height: AppSpacing.md),
          Text('Bir hata oluştu',
              style:
                  AppTypography.bodyMedium.copyWith(color: colors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: AppSpacing.screen,
      child: const Column(
        children: [
          SavvyShimmer(child: ShimmerBox(height: 80, radius: AppRadius.lg)),
          SizedBox(height: AppSpacing.md),
          SavvyShimmer(child: ShimmerBox(height: 280, radius: AppRadius.lg)),
          SizedBox(height: AppSpacing.md),
          SavvyShimmer(child: ShimmerBox(height: 200, radius: AppRadius.lg)),
        ],
      ),
    );
  }
}

// ─── Scenario Picker ─────────────────────────────────────────────────────────

class _ScenarioPicker extends StatelessWidget {
  final String label;
  final SimulationEntry? selected;
  final List<SimulationEntry> all;
  final SimulationEntry? exclude;
  final Color accentColor;
  final ValueChanged<SimulationEntry?> onChanged;

  const _ScenarioPicker({
    required this.label,
    required this.selected,
    required this.all,
    required this.exclude,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final available = all.where((s) => s != exclude).toList();

    return GestureDetector(
      onTap: () => _showPicker(context, c, available),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected != null
                ? accentColor.withValues(alpha: 0.5)
                : c.borderDefault,
            width: selected != null ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (selected == null) ...[
              Text(
                'Senaryo seç',
                style: AppTypography.bodySmall.copyWith(
                  color: c.textTertiary,
                ),
              ),
            ] else ...[
              Row(
                children: [
                  _TemplateIcon(
                    template: selected!.template,
                    size: 14,
                    color: accentColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      selected!.title,
                      style: AppTypography.labelSmall.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPicker(
    BuildContext context,
    dynamic c,
    List<SimulationEntry> available,
  ) {
    final colors = AppColors.of(context);
    showModalBottomSheet<SimulationEntry>(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: AppRadius.pill,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: AppSpacing.screenH,
                child: Text(
                  label,
                  style: AppTypography.headlineSmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (available.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Seçilebilecek başka senaryo yok.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: colors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    itemCount: available.length,
                    separatorBuilder: (ctx, i) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (_, i) {
                      final sim = available[i];
                      final isSelected = selected?.id == sim.id;
                      return _PickerTile(
                        sim: sim,
                        isSelected: isSelected,
                        accentColor: accentColor,
                        onTap: () {
                          Navigator.of(ctx).pop(sim);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    ).then((sim) {
      if (sim != null) onChanged(sim);
    });
  }
}

class _PickerTile extends StatelessWidget {
  final SimulationEntry sim;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _PickerTile({
    required this.sim,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : c.surfaceOverlay,
          borderRadius: AppRadius.chip,
          border: isSelected
              ? Border.all(color: accentColor.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          children: [
            _TemplateIcon(
              template: sim.template,
              size: 16,
              color: isSelected ? accentColor : c.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                sim.title,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? c.textPrimary : c.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(LucideIcons.check, size: 16, color: accentColor),
          ],
        ),
      ),
    );
  }
}

class _TemplateIcon extends StatelessWidget {
  final SimulationTemplate? template;
  final double size;
  final Color color;

  const _TemplateIcon({
    required this.template,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final icon = template?.icon ?? LucideIcons.sparkles;
    return Icon(icon, size: size, color: color);
  }
}

// ─── Comparison Table ─────────────────────────────────────────────────────────

class _ComparisonTable extends StatelessWidget {
  final SimulationEntry simA;
  final SimulationEntry simB;
  final SimulationResult resultA;
  final SimulationResult resultB;

  const _ComparisonTable({
    required this.simA,
    required this.simB,
    required this.resultA,
    required this.resultB,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final betterIsA = resultA.newNet >= resultB.newNet;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.cardLg,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        children: [
          // Header
          _TableHeader(
            simA: simA,
            simB: simB,
            betterIsA: betterIsA,
          ),
          const Divider(height: 1),

          // Metric rows
          _MetricRow(
            label: 'Aylık Etki',
            valueA: resultA.monthlyNetImpact,
            valueB: resultB.monthlyNetImpact,
            isCurrency: true,
            higherIsBetter: true,
          ),
          _MetricRow(
            label: 'Yıllık Etki',
            valueA: resultA.annualNetImpact,
            valueB: resultB.annualNetImpact,
            isCurrency: true,
            higherIsBetter: true,
          ),
          if (resultA.totalCost > 0 || resultB.totalCost > 0)
            _MetricRow(
              label: 'Toplam Maliyet',
              valueA: resultA.totalCost,
              valueB: resultB.totalCost,
              isCurrency: true,
              higherIsBetter: false,
            ),
          if (resultA.totalInterest > 0 || resultB.totalInterest > 0)
            _MetricRow(
              label: 'Toplam Faiz',
              valueA: resultA.totalInterest,
              valueB: resultB.totalInterest,
              isCurrency: true,
              higherIsBetter: false,
            ),
          _MetricRow(
            label: 'Yeni Gelir',
            valueA: resultA.newIncome,
            valueB: resultB.newIncome,
            isCurrency: true,
            higherIsBetter: true,
          ),
          _MetricRow(
            label: 'Yeni Gider',
            valueA: resultA.newExpense,
            valueB: resultB.newExpense,
            isCurrency: true,
            higherIsBetter: false,
          ),
          _MetricRow(
            label: 'Yeni Net',
            valueA: resultA.newNet,
            valueB: resultB.newNet,
            isCurrency: true,
            higherIsBetter: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final SimulationEntry simA;
  final SimulationEntry simB;
  final bool betterIsA;

  const _TableHeader({
    required this.simA,
    required this.simB,
    required this.betterIsA,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const colorA = Color(0xFF3F83F8);
    const colorB = Color(0xFF8B5CF6);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              'Metrik',
              style: AppTypography.caption.copyWith(
                color: c.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: _HeaderCell(
              sim: simA,
              label: 'Senaryo A',
              color: colorA,
              isBetter: betterIsA,
            ),
          ),
          Expanded(
            child: _HeaderCell(
              sim: simB,
              label: 'Senaryo B',
              color: colorB,
              isBetter: !betterIsA,
            ),
          ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final SimulationEntry sim;
  final String label;
  final Color color;
  final bool isBetter;

  const _HeaderCell({
    required this.sim,
    required this.label,
    required this.color,
    required this.isBetter,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            if (isBetter) ...[
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: c.income.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Daha iyi',
                  style: AppTypography.caption.copyWith(
                    color: c.income,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          sim.title,
          style: AppTypography.caption.copyWith(
            color: c.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double valueA;
  final double valueB;
  final bool isCurrency;
  final bool higherIsBetter;
  final bool isLast;

  const _MetricRow({
    required this.label,
    required this.valueA,
    required this.valueB,
    required this.isCurrency,
    required this.higherIsBetter,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final delta = valueA - valueB;
    // Positive delta means A is bigger
    final aIsLeading = higherIsBetter ? delta > 0 : delta < 0;
    final bIsLeading = higherIsBetter ? delta < 0 : delta > 0;

    Color deltaColor;
    IconData deltaIcon;
    if (delta == 0) {
      deltaColor = c.textTertiary;
      deltaIcon = LucideIcons.minus;
    } else if (aIsLeading) {
      deltaColor = c.income;
      deltaIcon = LucideIcons.arrowUp;
    } else {
      deltaColor = c.expense;
      deltaIcon = LucideIcons.arrowDown;
    }

    String fmt(double v) =>
        isCurrency ? CurrencyFormatter.compact(v) : v.toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: c.borderDefault, width: 0.5)),
        color: isLast ? c.surfaceOverlay.withValues(alpha: 0.4) : null,
        borderRadius: isLast
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xl))
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isLast ? c.textPrimary : c.textSecondary,
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: _ValueCell(
              value: fmt(valueA),
              isLeading: aIsLeading,
              color: const Color(0xFF3F83F8),
              c: c,
              isLast: isLast,
            ),
          ),
          Expanded(
            child: _ValueCell(
              value: fmt(valueB),
              isLeading: bIsLeading,
              color: const Color(0xFF8B5CF6),
              c: c,
              isLast: isLast,
            ),
          ),
          SizedBox(
            width: 52,
            child: delta == 0
                ? Center(
                    child: Icon(
                      LucideIcons.minus,
                      size: 12,
                      color: c.textTertiary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(deltaIcon, size: 10, color: deltaColor),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          isCurrency
                              ? CurrencyFormatter.compact(delta.abs())
                              : delta.abs().toStringAsFixed(0),
                          style: AppTypography.caption.copyWith(
                            color: deltaColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String value;
  final bool isLeading;
  final Color color;
  final dynamic c;
  final bool isLast;

  const _ValueCell({
    required this.value,
    required this.isLeading,
    required this.color,
    required this.c,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Text(
        value,
        style: AppTypography.numericSmall.copyWith(
          color: isLeading
              ? color
              : isLast
                  ? colors.textPrimary
                  : colors.textSecondary,
          fontWeight: isLeading ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── 12-Month Projection Table ────────────────────────────────────────────────

class _ProjectionTable extends StatelessWidget {
  final SimulationEntry simA;
  final SimulationEntry simB;
  final SimulationResult resultA;
  final SimulationResult resultB;

  const _ProjectionTable({
    required this.simA,
    required this.simB,
    required this.resultA,
    required this.resultB,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final projA = resultA.monthlyProjection;
    final projB = resultB.monthlyProjection;
    final count = projA.length < projB.length ? projA.length : projB.length;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.cardLg,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(LucideIcons.calendarDays,
                    size: 15, color: c.brandPrimary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '12 Aylık Projeksiyon',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Column header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Text('Ay',
                      style: AppTypography.caption.copyWith(
                          color: c.textTertiary,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: Text(
                    'A Net',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF3F83F8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'B Net',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    'Fark',
                    style: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: count,
            separatorBuilder: (ctx, i) =>
                Divider(height: 1, color: c.borderDefault.withValues(alpha: 0.5)),
            itemBuilder: (_, i) {
              final a = projA[i];
              final b = projB[i];
              final diff = a.net - b.net;
              final diffColor =
                  diff > 0 ? c.income : diff < 0 ? c.expense : c.textTertiary;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        a.monthLabel,
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        CurrencyFormatter.compact(a.net),
                        style: AppTypography.numericSmall.copyWith(
                          color: a.net >= 0 ? c.income : c.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        CurrencyFormatter.compact(b.net),
                        style: AppTypography.numericSmall.copyWith(
                          color: b.net >= 0 ? c.income : c.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        diff == 0
                            ? '—'
                            : '${diff > 0 ? '+' : ''}${CurrencyFormatter.compact(diff)}',
                        style: AppTypography.caption.copyWith(
                          color: diffColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
