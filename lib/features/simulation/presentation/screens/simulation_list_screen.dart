import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/dashboard/presentation/widgets/monthly_flow_table.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/features/simulation/presentation/screens/add_simulation_sheet.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const AddSimulationSheet(),
      ),
    );
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
                    Text(
                      'Simülasyonlar',
                      style: AppTypography.headlineMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
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
                    onMonthTap: (_) {},
                  ),
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
                  child: _StackedCards(
                    sims: sims,
                    expandAnimation: _expandCtrl,
                    onToggleInclude: (sim) {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(simulationProvider.notifier)
                          .toggleInclude(sim);
                    },
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

// ─── Stacked Cards Widget ─────────────────────────────────────
class _StackedCards extends StatelessWidget {
  final List<SimulationEntry> sims;
  final AnimationController expandAnimation;
  final void Function(SimulationEntry sim) onToggleInclude;
  final void Function(String id) onDelete;
  final VoidCallback onExpandToggle;

  static const _peekH = 44.0; // visible peek per stacked card
  static const _cardSpacing = 12.0; // spacing when expanded

  const _StackedCards({
    required this.sims,
    required this.expandAnimation,
    required this.onToggleInclude,
    required this.onDelete,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: expandAnimation,
      builder: (context, _) {
        final t = expandAnimation.value; // 0 = stacked, 1 = expanded
        return GestureDetector(
          // Drag to expand/collapse
          onVerticalDragUpdate: (d) {
            final delta = d.primaryDelta ?? 0;
            expandAnimation.value =
                (expandAnimation.value + delta / 300).clamp(0.0, 1.0);
          },
          onVerticalDragEnd: (d) {
            final vel = d.primaryVelocity ?? 0;
            if (vel > 200) {
              // Swiped down → expand
              expandAnimation.forward();
            } else if (vel < -200) {
              // Swiped up → collapse
              expandAnimation.reverse();
            } else {
              // Snap to nearest
              if (expandAnimation.value > 0.5) {
                expandAnimation.forward();
              } else {
                expandAnimation.reverse();
              }
            }
          },
          child: _buildStack(context, t),
        );
      },
    );
  }

  Widget _buildStack(BuildContext context, double t) {
    final count = sims.length;
    if (count == 0) return const SizedBox.shrink();

    // Calculate heights
    // Collapsed: first card full + remaining cards peek
    // Expanded: all cards full with spacing
    final children = <Widget>[];

    for (int i = 0; i < count; i++) {
      // In collapsed: card i is offset by i * peekH from top
      // In expanded: card i is positioned naturally (no overlap)
      // Scale: back cards slightly smaller when collapsed
      final collapsedScale = 1.0 - (i * 0.02).clamp(0.0, 0.08);
      final scale = collapsedScale + (1.0 - collapsedScale) * t;

      // Opacity for deeply stacked cards
      final collapsedOpacity =
          i < 4 ? 1.0 : (1.0 - ((i - 3) * 0.3)).clamp(0.3, 1.0);
      final opacity = collapsedOpacity + (1.0 - collapsedOpacity) * t;

      children.add(
        AnimatedBuilder(
          animation: expandAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: t * _cardSpacing,
            ),
            child: _FlipSimCard(
              sim: sims[i],
              onToggleInclude: () => onToggleInclude(sims[i]),
              onDelete: () => onDelete(sims[i].id),
            ),
          ),
        ),
      );
    }

    if (t < 0.05) {
      // Fully collapsed: use Stack with positioned cards
      final stackHeight = _peekH * (count - 1) + 170; // last card full height
      return SizedBox(
        height: stackHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(count, (i) {
            final reverseI = count - 1 - i; // draw bottom cards first
            final idx = reverseI;
            final top = idx * _peekH;
            final cardScale = 1.0 - (idx * 0.02).clamp(0.0, 0.08);
            final cardOpacity =
                idx < 4 ? 1.0 : (1.0 - ((idx - 3) * 0.3)).clamp(0.3, 1.0);

            return Positioned(
              top: top,
              left: 0,
              right: 0,
              child: Transform.scale(
                scale: cardScale,
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: cardOpacity,
                  child: _FlipSimCard(
                    sim: sims[idx],
                    onToggleInclude: () => onToggleInclude(sims[idx]),
                    onDelete: () => onDelete(sims[idx].id),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    if (t > 0.95) {
      // Fully expanded: simple Column
      return Column(
        children: List.generate(count, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: _cardSpacing),
            child: _FlipSimCard(
              sim: sims[i],
              onToggleInclude: () => onToggleInclude(sims[i]),
              onDelete: () => onDelete(sims[i].id),
            ),
          );
        }),
      );
    }

    // Mid-animation: interpolate between stack and column layout
    // Use Stack with animated positions
    final collapsedTotalH = _peekH * (count - 1) + 170;
    final expandedTotalH = count * (170 + _cardSpacing);
    final totalH = collapsedTotalH + (expandedTotalH - collapsedTotalH) * t;

    return SizedBox(
      height: totalH,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(count, (rawI) {
          // Draw from back to front in collapsed, normal in expanded
          final i = rawI;
          final collapsedTop = i * _peekH;
          final expandedTop = i * (170 + _cardSpacing);
          final top = collapsedTop + (expandedTop - collapsedTop) * t;

          final cardScale = (1.0 - (i * 0.02).clamp(0.0, 0.08)) +
              ((i * 0.02).clamp(0.0, 0.08)) * t;
          final cardOpacity = i < 4
              ? 1.0
              : ((1.0 - ((i - 3) * 0.3)).clamp(0.3, 1.0) +
                  ((i - 3) * 0.3).clamp(0.0, 0.7) * t);

          return Positioned(
            top: top,
            left: 0,
            right: 0,
            child: Transform.scale(
              scale: cardScale,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: cardOpacity.clamp(0.0, 1.0),
                child: _FlipSimCard(
                  sim: sims[i],
                  onToggleInclude: () => onToggleInclude(sims[i]),
                  onDelete: () => onDelete(sims[i].id),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Flip Simulation Card ─────────────────────────────────────
class _FlipSimCard extends StatefulWidget {
  final SimulationEntry sim;
  final VoidCallback onToggleInclude;
  final VoidCallback onDelete;

  const _FlipSimCard({
    required this.sim,
    required this.onToggleInclude,
    required this.onDelete,
  });

  @override
  State<_FlipSimCard> createState() => _FlipSimCardState();
}

class _FlipSimCardState extends State<_FlipSimCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    if (_showBack) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    _showBack = !_showBack;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (context, _) {
        final angle = _flipAnim.value * math.pi;
        final isFront = angle < math.pi / 2;

        return GestureDetector(
          onTap: _flip,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? _FrontCard(
                    sim: widget.sim,
                    onToggleInclude: widget.onToggleInclude,
                    onDelete: widget.onDelete,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _BackCard(sim: widget.sim),
                  ),
          ),
        );
      },
    );
  }
}

// ─── Front Card ─────────────────────────────────────────────
class _FrontCard extends StatelessWidget {
  final SimulationEntry sim;
  final VoidCallback onToggleInclude;
  final VoidCallback onDelete;

  const _FrontCard({
    required this.sim,
    required this.onToggleInclude,
    required this.onDelete,
  });

  /// Category-specific decorative icon (large, faded in background)
  IconData get _decoIcon => switch (sim.type) {
        SimulationType.car => LucideIcons.car,
        SimulationType.housing => LucideIcons.home,
        SimulationType.credit => LucideIcons.creditCard,
        SimulationType.vacation => LucideIcons.palmtree,
        SimulationType.tech => LucideIcons.smartphone,
        SimulationType.custom => LucideIcons.sparkles,
      };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final typeColor = sim.type.color;
    final params = sim.parameters;
    final principal = (params['principal'] as num?)?.toDouble() ?? 0;
    final monthlyPayment = (params['monthlyPayment'] as num?)?.toDouble();
    final termMonths = (params['termMonths'] as num?)?.toInt();
    final downPayment = (params['downPayment'] as num?)?.toDouble() ?? 0;
    final progress =
        principal > 0 ? (downPayment / principal).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardLg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withValues(alpha: 0.12),
            typeColor.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.2),
          width: sim.isIncluded ? 2 : 1,
        ),
        boxShadow: [
          if (sim.isIncluded)
            BoxShadow(
              color: typeColor.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.cardLg,
        child: Stack(
          children: [
            // Decorative background icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                _decoIcon,
                size: 80,
                color: typeColor.withValues(alpha: 0.06),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: include toggle + type badge + delete
                  Row(
                    children: [
                      // Include toggle
                      GestureDetector(
                        onTap: onToggleInclude,
                        child: AnimatedContainer(
                          duration: AppDuration.fast,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: sim.isIncluded
                                ? typeColor.withValues(alpha: 0.15)
                                : c.surfaceOverlay,
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: sim.isIncluded
                                  ? typeColor.withValues(alpha: 0.4)
                                  : c.borderDefault
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                sim.isIncluded
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 14,
                                color: sim.isIncluded
                                    ? typeColor
                                    : c.textTertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sim.isIncluded
                                    ? 'Dahil'
                                    : 'Dahil Et',
                                style: AppTypography.caption.copyWith(
                                  color: sim.isIncluded
                                      ? typeColor
                                      : c.textTertiary,
                                  fontWeight: sim.isIncluded
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(sim.type.icon,
                                size: 11, color: typeColor),
                            const SizedBox(width: 4),
                            Text(
                              sim.type.label,
                              style: AppTypography.caption.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Delete
                      GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c.expense.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.trash2,
                              size: 13, color: c.expense),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    sim.title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Principal amount
                  if (principal > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatNoDecimal(principal),
                      style: AppTypography.numericLarge.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // Progress bar (down payment)
                  if (principal > 0) ...[
                    ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            c.textTertiary.withValues(alpha: 0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(typeColor),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  // Bottom row: monthly payment + term + flip hint
                  Row(
                    children: [
                      if (monthlyPayment != null)
                        Text(
                          '${CurrencyFormatter.formatNoDecimal(monthlyPayment)}/ay',
                          style: AppTypography.labelSmall.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const Spacer(),
                      if (termMonths != null)
                        Text(
                          '$termMonths ay',
                          style: AppTypography.caption.copyWith(
                            color: c.textTertiary,
                          ),
                        ),
                      const SizedBox(width: AppSpacing.md),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.rotateCcw,
                              size: 11, color: c.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Özet',
                            style: AppTypography.caption.copyWith(
                              color: c.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Back Card (Summary) ──────────────────────────────────────
class _BackCard extends StatelessWidget {
  final SimulationEntry sim;

  const _BackCard({required this.sim});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final typeColor = sim.type.color;
    final params = sim.parameters;
    final monthlyPayment =
        (params['monthlyPayment'] as num?)?.toDouble();
    final totalPayment =
        (params['totalPayment'] as num?)?.toDouble();
    final totalInterest =
        (params['totalInterest'] as num?)?.toDouble();
    final termMonths = (params['termMonths'] as num?)?.toInt();

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardLg,
        color: c.surfaceCard,
        border: Border.all(
          color: typeColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(sim.type.icon, size: 18, color: typeColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    sim.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.rotateCcw,
                        size: 11, color: c.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Geri',
                      style: AppTypography.caption.copyWith(
                        color: c.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Divider(
              color: c.borderDefault.withValues(alpha: 0.3),
              height: AppSpacing.xl,
            ),

            // Summary 2x2 grid
            Row(
              children: [
                Expanded(
                  child: _SummaryCell(
                    label: 'Aylık Taksit',
                    value: monthlyPayment != null
                        ? CurrencyFormatter.formatNoDecimal(
                            monthlyPayment)
                        : '-',
                    icon: LucideIcons.calendar,
                    color: c.brandPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryCell(
                    label: 'Toplam Ödeme',
                    value: totalPayment != null
                        ? CurrencyFormatter.formatNoDecimal(
                            totalPayment)
                        : '-',
                    icon: LucideIcons.banknote,
                    color: c.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _SummaryCell(
                    label: 'Toplam Faiz',
                    value: totalInterest != null
                        ? CurrencyFormatter.formatNoDecimal(
                            totalInterest)
                        : '-',
                    icon: LucideIcons.percent,
                    color: c.expense,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _SummaryCell(
                    label: 'Vade',
                    value:
                        termMonths != null ? '$termMonths ay' : '-',
                    icon: LucideIcons.clock,
                    color: c.savings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Cell ─────────────────────────────────────────────
class _SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceOverlay.withValues(alpha: 0.5),
        borderRadius: AppRadius.card,
        border:
            Border.all(color: c.borderDefault.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.numericMedium.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
