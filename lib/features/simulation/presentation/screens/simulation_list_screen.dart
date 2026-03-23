import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/simulation/presentation/providers/simulation_provider.dart';
import 'package:savvy/features/simulation/presentation/screens/add_simulation_sheet.dart';
import 'package:savvy/features/simulation/presentation/widgets/simulation_card.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

class SimulationListScreen extends ConsumerWidget {
  const SimulationListScreen({super.key});

  void _openAddSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet,
      ),
      builder: (_) => const AddSimulationSheet(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    final c = AppColors.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLg),
        title: Text(
          'Simülasyonu Sil',
          style: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
        ),
        content: Text(
          'Bu simülasyon kalıcı olarak silinecek. Devam etmek istiyor musunuz?',
          style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'İptal',
              style: AppTypography.labelLarge.copyWith(color: c.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(simulationProvider.notifier)
                  .deleteSimulation(id);
            },
            child: Text(
              'Sil',
              style: AppTypography.labelLarge.copyWith(color: c.expense),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationsAsync = ref.watch(allSimulationsProvider);
    final c = AppColors.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
            child: Row(
              children: [
                Text(
                  'Simülasyonlar',
                  style: AppTypography.headlineMedium
                      .copyWith(color: c.textPrimary),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _openAddSheet(context),
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
                      boxShadow: [
                        BoxShadow(
                          color: c.brandPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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

          const SizedBox(height: AppSpacing.base),

          // List
          Expanded(
            child: simulationsAsync.when(
              loading: () => _buildShimmer(),
              error: (e, _) => Center(
                child: Text(
                  'Bir hata oluştu',
                  style:
                      AppTypography.bodyMedium.copyWith(color: c.textSecondary),
                ),
              ),
              data: (simulations) {
                if (simulations.isEmpty) {
                  return EmptyState(
                    icon: LucideIcons.sparkles,
                    title: 'Henüz simülasyon yok',
                    subtitle:
                        'Finansal senaryolarınızı oluşturun ve analiz edin.',
                    actionLabel: 'İlk Simülasyonu Oluştur',
                    onAction: () => _openAddSheet(context),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xl5 + AppSpacing.xl2,
                  ),
                  itemCount: simulations.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final sim = simulations[index];
                    return SimulationCard(
                      simulation: sim,
                      onTap: () => context.go('/simulate/${sim.id}'),
                      onLongPress: () =>
                          _confirmDelete(context, ref, sim.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: AppSpacing.screenH,
      child: Column(
        children: List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: SavvyShimmer(
              child: ShimmerBox(height: 80, radius: AppRadius.xl),
            ),
          ),
        ),
      ),
    );
  }
}
