import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/savvy_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/domain/models/simulation_result.dart';
import 'package:savvy/features/simulation/domain/simulation_calculator.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';

/// Shows 12-month cash flow projection with itemized income/expense lines.
class SimulationCashFlowScreen extends ConsumerWidget {
  final String simulationId;

  const SimulationCashFlowScreen({super.key, required this.simulationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final simsAsync = ref.watch(allSimulationsProvider);

    return simsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (sims) {
        final entry =
            sims.where((s) => s.id == simulationId).firstOrNull;
        if (entry == null) {
          return Scaffold(
            body: Center(
              child: Text('Simülasyon bulunamadı',
                  style: AppTypography.titleMedium
                      .copyWith(color: c.textSecondary)),
            ),
          );
        }

        final budget = ref.read(allMonthSummariesProvider);
        final currentBudget =
            budget.isNotEmpty ? budget.first : null;
        if (currentBudget == null) {
          return Scaffold(
            body: Center(
              child: Text('Bütçe verisi bulunamadı',
                  style: AppTypography.titleMedium
                      .copyWith(color: c.textSecondary)),
            ),
          );
        }

        final result = SimulationCalculator.calculateScenario(
          changes: entry.changes,
          currentBudget: currentBudget,
          baseItems: ref.watch(projectionBaseItemsProvider),
        );

        final color = _parseColor(entry);

        return Scaffold(
          backgroundColor: c.surfaceBackground,
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  leading: IconButton(
                    icon: Icon(LucideIcons.chevronLeft,
                        color: c.textPrimary),
                    onPressed: () =>
                        context.go('/simulate/$simulationId'),
                  ),
                  title: Text('Aylık Akış Detayı',
                      style: AppTypography.titleLarge
                          .copyWith(color: c.textPrimary)),
                  centerTitle: false,
                ),
                SliverPadding(
                  padding: AppSpacing.screenH,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final month = result.monthlyProjection[index];
                        return _MonthCard(
                          month: month,
                          color: color,
                          isFirst: index == 0,
                        );
                      },
                      childCount: result.monthlyProjection.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(SimulationEntry entry) {
    try {
      final hex = entry.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return entry.template?.color ?? const Color(0xFF3F83F8);
    }
  }
}

// ─── Month Card ──────────────────────────────────────────────────

class _MonthCard extends StatefulWidget {
  final MonthProjection month;
  final Color color;
  final bool isFirst;

  const _MonthCard({
    required this.month,
    required this.color,
    required this.isFirst,
  });

  @override
  State<_MonthCard> createState() => _MonthCardState();
}

class _MonthCardState extends State<_MonthCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isFirst;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final m = widget.month;
    final isPositiveNet = m.net >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: _expanded
              ? widget.color.withValues(alpha: 0.3)
              : c.borderDefault.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Header — always visible
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: _expanded
                    ? widget.color.withValues(alpha: 0.04)
                    : Colors.transparent,
                borderRadius: _expanded
                    ? AppRadius.topOnly
                    : AppRadius.card,
              ),
              child: Row(
                children: [
                  // Month label
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Center(
                      child: Text(
                        m.monthLabel,
                        style: AppTypography.labelMedium.copyWith(
                          color: widget.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Income / Expense summary
                  Expanded(
                    child: Row(
                      children: [
                        _MiniStat(
                          label: 'Gelir',
                          value: CurrencyFormatter.compact(m.income),
                          color: c.income,
                        ),
                        const SizedBox(width: AppSpacing.base),
                        _MiniStat(
                          label: 'Gider',
                          value: CurrencyFormatter.compact(m.expense),
                          color: c.expense,
                        ),
                      ],
                    ),
                  ),

                  // Net
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatNoDecimal(m.net),
                        style: AppTypography.numericSmall.copyWith(
                          color: isPositiveNet ? c.income : c.expense,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text('net',
                          style: AppTypography.caption.copyWith(
                              color: c.textTertiary, fontSize: 9)),
                    ],
                  ),

                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppDuration.fast,
                    child: Icon(LucideIcons.chevronDown,
                        size: 16, color: c.textTertiary),
                  ),
                ],
              ),
            ),
          ),

          // Expanded detail — itemized lines
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildDetail(context, c, m),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppDuration.normal,
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(
      BuildContext context, SavvyColors c, MonthProjection m) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.base, 0, AppSpacing.base, AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: c.borderDefault.withValues(alpha: 0.3)),

          // Income items
          if (m.incomeItems.isNotEmpty) ...[
            _SectionLabel(
                label: 'Gelirler',
                icon: LucideIcons.trendingUp,
                color: c.income),
            ...m.incomeItems.map((item) => _LineItemRow(
                  item: item,
                  color: c.income,
                )),
          ],

          if (m.incomeItems.isNotEmpty && m.expenseItems.isNotEmpty)
            const SizedBox(height: AppSpacing.md),

          // Expense items
          if (m.expenseItems.isNotEmpty) ...[
            _SectionLabel(
                label: 'Giderler',
                icon: LucideIcons.trendingDown,
                color: c.expense),
            ...m.expenseItems.map((item) => _LineItemRow(
                  item: item,
                  color: c.expense,
                )),
          ],

          // Cumulative net
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.06),
              borderRadius: AppRadius.chip,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kümülatif Net',
                    style: AppTypography.labelSmall
                        .copyWith(color: c.textSecondary)),
                Text(
                  CurrencyFormatter.formatNoDecimal(m.cumulativeNet),
                  style: AppTypography.numericSmall.copyWith(
                    color: m.cumulativeNet >= 0 ? c.income : c.expense,
                    fontWeight: FontWeight.w700,
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

// ─── Section Label ───────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Line Item Row ───────────────────────────────────────────────

class _LineItemRow extends StatelessWidget {
  final MonthLineItem item;
  final Color color;

  const _LineItemRow({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.lg),
          if (item.isSimulated)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: AppSpacing.sm),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              item.label,
              style: AppTypography.bodySmall.copyWith(
                color: item.isSimulated ? color : c.textSecondary,
                fontWeight:
                    item.isSimulated ? FontWeight.w600 : FontWeight.w400,
                fontStyle:
                    item.isSimulated ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.formatNoDecimal(item.amount),
            style: AppTypography.numericSmall.copyWith(
              color: item.isSimulated ? color : c.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat ───────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textTertiary, fontSize: 9)),
        Text(value,
            style: AppTypography.numericSmall.copyWith(
                color: color, fontWeight: FontWeight.w600, fontSize: 12)),
      ],
    );
  }
}
