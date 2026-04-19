import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/dashboard/presentation/widgets/monthly_flow_table.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/features/simulation/presentation/widgets/sim_stacked_cards.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class SimulationListScreen extends ConsumerStatefulWidget {
  const SimulationListScreen({super.key});

  @override
  ConsumerState<SimulationListScreen> createState() =>
      _SimulationListScreenState();
}

class _SimulationListScreenState extends ConsumerState<SimulationListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandCtrl;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.lightImpact();
    if (_isExpanded) {
      _expandCtrl.reverse();
    } else {
      _expandCtrl.forward();
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  void _openAddPage() {
    HapticFeedback.lightImpact();
    context.go('/simulate/new');
  }

  Future<void> _handleToggleInclude(SimulationEntry sim) async {
    // Toggle off → onay ile çıkar
    if (sim.isIncluded) {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tablodan Çıkar'),
          content: Text('"${sim.title}" simülasyonu aylık akış tablonuzdan çıkarılsın mı?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Çıkar')),
          ],
        ),
      );
      if (confirmed == true) {
        HapticFeedback.mediumImpact();
        ref.read(simulationProvider.notifier).toggleInclude(sim);
      }
      return;
    }

    // Toggle on → her seferinde onay popup'ı göster
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aylık Akışa Dahil Et'),
        content: Text('"${sim.title}" simülasyonu aylık akış tablonuza dahil edilsin mi?\n\nGelir ve gider etkileri tahmini aylara yansıtılacak.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('İptal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Dahil Et')),
        ],
      ),
    );
    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      ref.read(simulationProvider.notifier).toggleInclude(sim);
    }
  }


  void _confirmDelete(String id) {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLg),
        title: Text('Simülasyonu Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: c.textPrimary)),
        content: Text(
          'Bu simülasyon kalıcı olarak silinecek.',
          style:
              AppTypography.bodyMedium.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal',
                style: AppTypography.labelLarge
                    .copyWith(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(simulationProvider.notifier).deleteSimulation(id);
            },
            child: Text('Sil',
                style:
                    AppTypography.labelLarge.copyWith(color: c.expense)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simsAsync = ref.watch(allSimulationsProvider);
    final c = AppColors.of(context);

    return SafeArea(
      child: simsAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => _buildError(c, e),
        data: (sims) => _buildContent(c, sims),
      ),
    );
  }

  Widget _buildContent(dynamic c, List<SimulationEntry> sims) {
    final colors = AppColors.of(context);
    // Get simulation-aware projections
    final projections = ref.watch(simulationAwareProjectionsProvider);
    final summaries = ref.watch(allMonthSummariesProvider);
    final includeSavings = ref.watch(includeSavingsInProjectionProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Simülasyonlar',
                        style: AppTypography.headlineMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.go('/simulate/compare');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceOverlay,
                          borderRadius: AppRadius.pill,
                          border: Border.all(color: colors.borderDefault),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.compare_arrows_rounded,
                              size: 16,
                              color: colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Karşılaştır',
                              style: AppTypography.labelSmall.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: _openAddPage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.brandPrimaryDim,
                              colors.brandPrimary,
                            ],
                          ),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Oluştur',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Monthly Flow Table ─────────────────────────
              if (summaries.isNotEmpty || projections.isNotEmpty)
                Padding(
                  padding: AppSpacing.screenH,
                  child: MonthlyFlowTable(
                    summaries: summaries,
                    projections: projections,
                    includeSavings: includeSavings,
                    includedSimulations: sims.where((s) => s.isIncluded).toList(),
                    onMonthTap: (_) {},
                    showDetailHint: false,
                  ),
                ),

              // Dahil edilen simülasyon bilgisi — tablonun hemen altında, minimal
              if (sims.any((s) => s.isIncluded))
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.sm,
                  ),
                  child: _IncludedSimsChip(sims: sims),
                ),

              const SizedBox(height: AppSpacing.xl),

              // ── Simulation Cards ───────────────────────────
              if (sims.isEmpty) _buildEmptyInline(colors),

              // ── Stacked Cards ──────────────────────────────
              if (sims.isNotEmpty) ...[
                // Stack header with expand hint
                Padding(
                  padding: AppSpacing.screenH,
                  child: GestureDetector(
                    onTap: _toggleExpand,
                    child: Row(
                      children: [
                        Container(
                          width: 2,
                          height: 16,
                          margin: const EdgeInsets.only(
                              right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: colors.brandPrimary,
                            borderRadius: AppRadius.pill,
                          ),
                        ),
                        Text(
                          'Simülasyonlarım',
                          style: AppTypography.headlineSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.surfaceOverlay,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            '${sims.length} senaryo',
                            style: AppTypography.caption.copyWith(
                              color: colors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _expandCtrl,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _expandCtrl.value * math.pi,
                              child: Icon(
                                LucideIcons.chevronDown,
                                size: 18,
                                color: colors.textTertiary,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // The animated stacked/expanded cards
                Padding(
                  padding: AppSpacing.screenH,
                  child: SimStackedCards(
                    sims: sims,
                    expandAnimation: _expandCtrl,
                    onToggleInclude: _handleToggleInclude,
                    onDelete: (id) => _confirmDelete(id),
                    onExpandToggle: _toggleExpand,
                  ),
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyInline(dynamic c) {
    final colors = AppColors.of(context);
    return Padding(
      padding: AppSpacing.screenH,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl2),
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: AppRadius.cardLg,
          border: Border.all(
            color: colors.borderDefault.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.sparkles,
                  size: 28, color: colors.brandPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Henüz simülasyon yok',
              style: AppTypography.titleMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Senaryolarınızı oluşturup\naylık akışa etkisini görün',
              style: AppTypography.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: _openAddPage,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('İlk Simülasyonu Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
          ],
        ),
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
              style: AppTypography.bodyMedium
                  .copyWith(color: colors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text('$error',
              style: AppTypography.caption
                  .copyWith(color: colors.textTertiary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: AppSpacing.screenH,
      child: const Column(
        children: [
          SizedBox(height: AppSpacing.xl2),
          SavvyShimmer(
            child: ShimmerBox(height: 200, radius: AppRadius.xl),
          ),
          SizedBox(height: AppSpacing.lg),
          SavvyShimmer(
            child: ShimmerBox(height: 160, radius: AppRadius.xl),
          ),
          SizedBox(height: AppSpacing.md),
          SavvyShimmer(
            child: ShimmerBox(height: 160, radius: AppRadius.xl),
          ),
        ],
      ),
    );
  }
}

/// Banner shown at the top of the list when one or more simulations are included.
/// Displays the count and net monthly impact of all included simulations.
class _IncludedSimsChip extends StatelessWidget {
  final List<SimulationEntry> sims;

  const _IncludedSimsChip({required this.sims});

  @override
  Widget build(BuildContext context) {
    final included = sims.where((s) => s.isIncluded).toList();
    if (included.isEmpty) return const SizedBox.shrink();

    double totalExpense = 0;
    double totalIncome = 0;
    for (final sim in included) {
      totalExpense += simulationMonthlyPayment(sim);
      totalIncome += simulationMonthlyIncome(sim);
    }

    final c = AppColors.of(context);
    final netImpact = totalIncome - totalExpense;
    final simNames = included.map((s) => s.title).join(', ');
    final impactColor = netImpact > 0 ? c.income : netImpact < 0 ? c.expense : c.savings;

    return RichText(
      text: TextSpan(
        style: AppTypography.bodySmall.copyWith(
          color: c.textSecondary,
          fontSize: 13,
        ),
        children: [
          TextSpan(
            text: simNames,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' dahil · aylık net etki: '),
          TextSpan(
            text: CurrencyFormatter.withSign(netImpact),
            style: TextStyle(
              color: impactColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
