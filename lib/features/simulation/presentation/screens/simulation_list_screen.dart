import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/simulation/domain/models/simulation_entry.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/core/design/tokens/savvy_colors.dart';
import 'package:savvy/features/simulation/presentation/screens/add_simulation_sheet.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class SimulationListScreen extends ConsumerStatefulWidget {
  const SimulationListScreen({super.key});

  @override
  ConsumerState<SimulationListScreen> createState() =>
      _SimulationListScreenState();
}

class _SimulationListScreenState extends ConsumerState<SimulationListScreen> {
  final PageController _pageController =
      PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        data: (sims) => sims.isEmpty ? _buildEmpty(c) : _buildContent(c, sims),
      ),
    );
  }

  Widget _buildContent(SavvyColors c, List<SimulationEntry> sims) {
    final activeSim =
        _currentPage < sims.length ? sims[_currentPage] : sims.first;
    final params = activeSim.parameters;
    final monthlyPayment = (params['monthlyPayment'] as num?)?.toDouble();
    final totalPayment = (params['totalPayment'] as num?)?.toDouble();
    final totalInterest = (params['totalInterest'] as num?)?.toDouble();
    final termMonths = (params['termMonths'] as num?)?.toInt();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Text(
                      'Simülasyonlarım',
                      style: AppTypography.headlineMedium.copyWith(
                        color: c.textPrimary,
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
                            colors: [c.brandPrimaryDim, c.brandPrimary],
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
                              'Yeni',
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

              // ─── Carousel ─────────────────────────────────────
              SizedBox(
                height: 190,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: sims.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _SimCard(
                      sim: sims[index],
                      isActive: index == _currentPage,
                      onTap: () =>
                          context.go('/simulate/${sims[index].id}'),
                      onLongPress: () => _confirmDelete(sims[index].id),
                      onDelete: () => _confirmDelete(sims[index].id),
                    );
                  },
                ),
              ),

              // Page indicator dots
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  sims.length,
                  (i) => AnimatedContainer(
                    duration: AppDuration.fast,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentPage
                          ? c.brandPrimary
                          : c.textTertiary.withValues(alpha: 0.3),
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ─── Summary Panel (2x2 grid) ─────────────────────
              if (monthlyPayment != null)
                Padding(
                  padding: AppSpacing.screenH,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Özet',
                        style: AppTypography.titleMedium.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryMiniCard(
                              label: 'Aylık Taksit',
                              value: CurrencyFormatter.formatNoDecimal(
                                  monthlyPayment),
                              icon: LucideIcons.calendar,
                              color: c.brandPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _SummaryMiniCard(
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
                            child: _SummaryMiniCard(
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
                            child: _SummaryMiniCard(
                              label: 'Vade',
                              value: termMonths != null
                                  ? '$termMonths ay'
                                  : '-',
                              icon: LucideIcons.clock,
                              color: c.savings,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(SavvyColors c) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenH,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: c.brandPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.sparkles,
                  size: 36, color: c.brandPrimary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Henüz simülasyon yok',
              style: AppTypography.headlineSmall.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Araç veya ev alımı senaryolarınızı\noluşturup analiz edin.',
              style: AppTypography.bodyMedium.copyWith(
                color: c.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _openAddPage,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('İlk Simülasyonu Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.brandPrimary,
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

  Widget _buildError(SavvyColors c, Object error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertCircle, size: 40, color: c.expense),
          const SizedBox(height: AppSpacing.md),
          Text('Bir hata oluştu',
              style: AppTypography.bodyMedium
                  .copyWith(color: c.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text('$error',
              style:
                  AppTypography.caption.copyWith(color: c.textTertiary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: AppSpacing.screenH,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl2),
          const SavvyShimmer(
            child: ShimmerBox(height: 190, radius: AppRadius.xl),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SavvyShimmer(
            child: Row(
              children: [
                Expanded(child: ShimmerBox(height: 90)),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: ShimmerBox(height: 90)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Simulation Carousel Card ──────────────────────────────────
class _SimCard extends StatelessWidget {
  final SimulationEntry sim;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const _SimCard({
    required this.sim,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final typeColor = sim.type.color;
    final params = sim.parameters;
    final principal = (params['principal'] as num?)?.toDouble() ?? 0;
    final downPayment = (params['downPayment'] as num?)?.toDouble() ?? 0;
    final monthlyPayment =
        (params['monthlyPayment'] as num?)?.toDouble();
    final termMonths = (params['termMonths'] as num?)?.toInt();
    final progress =
        principal > 0 ? (downPayment / principal).clamp(0.0, 1.0) : 0.0;

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.92,
      duration: AppDuration.normal,
      curve: AppCurve.standard,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.6,
        duration: AppDuration.normal,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  typeColor.withValues(alpha: 0.15),
                  typeColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: typeColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge + name
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.15),
                              borderRadius: AppRadius.pill,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(sim.type.icon,
                                    size: 12, color: typeColor),
                                const SizedBox(width: 4),
                                Text(
                                  sim.type.label,
                                  style:
                                      AppTypography.caption.copyWith(
                                    color: typeColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c.expense.withValues(alpha: 0.1),
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

                      // Price
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

                      const Spacer(),

                      // Progress bar
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

                      // Bottom row
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Summary Mini Card ─────────────────────────────────────────
class _SummaryMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryMiniCard({
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
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        border:
            Border.all(color: c.borderDefault.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary,
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
