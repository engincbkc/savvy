import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/year_month_helper.dart';
import 'package:savvy/features/budget/presentation/providers/budget_provider.dart';
import 'package:savvy/features/budget/presentation/widgets/budget_progress_card.dart';
import 'package:savvy/features/budget/presentation/widgets/budget_setup_sheet.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class BudgetOverviewScreen extends ConsumerWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final limitsAsync = ref.watch(budgetLimitsProvider);
    final currentMonth = DateTime.now().toYearMonth();
    final usage = ref.watch(budgetUsageProvider(currentMonth));

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: limitsAsync.when(
          loading: () => SavvyShimmer(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: ShimmerBox(height: 100, radius: AppRadius.lg),
                ),
              ),
            ),
          ),
          error: (e, _) => Center(
            child: Text(
              'Bir hata oluştu: $e',
              style: AppTypography.bodyMedium
                  .copyWith(color: colors.textSecondary),
            ),
          ),
          data: (limits) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: AppRadius.chip,
                              ),
                              child: const Icon(
                                LucideIcons.wallet,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bütçe Limitleri',
                                    style: AppTypography.headlineSmall
                                        .copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    'Aylık harcama sınırlarını yönet',
                                    style: AppTypography.bodySmall.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Add button in header
                            GestureDetector(
                              onTap: () => _openSetupSheet(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: AppRadius.chip,
                                ),
                                child: const Icon(
                                  LucideIcons.plus,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (limits.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _SummaryRow(
                            limits: limits,
                            usage: usage,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Empty state
                if (limits.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyBudgetState(
                      onAdd: () => _openSetupSheet(context),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      100,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final limit = limits[index];
                          final spent = usage[limit.category] ?? 0.0;
                          return BudgetProgressCard(
                            limit: limit,
                            spent: spent,
                            onEdit: () =>
                                _openSetupSheet(context, existing: limit),
                            onDelete: () =>
                                _confirmDelete(context, ref, limit.id),
                          );
                        },
                        childCount: limits.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: limitsAsync.value?.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () => _openSetupSheet(context),
              backgroundColor: colors.brandPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(
                'Limit Ekle',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _openSetupSheet(BuildContext context,
      {dynamic existing}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BudgetSetupSheet(existing: existing),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limiti Sil'),
        content: const Text('Bu bütçe limitini silmek istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(budgetLimitProvider.notifier).softDelete(id);
            },
            child: Text(
              'Sil',
              style: TextStyle(color: AppColors.of(context).error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List limits;
  final Map usage;

  const _SummaryRow({required this.limits, required this.usage});

  @override
  Widget build(BuildContext context) {
    int overCount = 0;
    int warningCount = 0;
    int okCount = 0;

    for (final limit in limits) {
      final spent = (usage[limit.category] ?? 0.0) as double;
      final ratio =
          limit.monthlyLimit > 0 ? spent / limit.monthlyLimit : 0.0;
      if (ratio > 1.0) {
        overCount++;
      } else if (ratio > 0.8) {
        warningCount++;
      } else {
        okCount++;
      }
    }

    return Row(
      children: [
        _SummaryChip(
            count: okCount, label: 'Normal', color: Colors.white70),
        const SizedBox(width: AppSpacing.sm),
        if (warningCount > 0)
          _SummaryChip(
              count: warningCount,
              label: 'Uyarı',
              color: const Color(0xFFFBBF24)),
        if (warningCount > 0) const SizedBox(width: AppSpacing.sm),
        if (overCount > 0)
          _SummaryChip(
              count: overCount,
              label: 'Aşıldı',
              color: const Color(0xFFF87171)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryChip(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        '$count $label',
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyBudgetState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.brandPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.wallet,
                size: 32,
                color: colors.brandPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Henüz bütçe limiti belirlemediniz',
              style: AppTypography.headlineSmall
                  .copyWith(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Kategori bazlı aylık harcama sınırları belirleyerek\nharcamalarını kontrol altında tut.',
              style: AppTypography.bodyMedium
                  .copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.input,
                ),
              ),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: Text(
                'İlk Limitini Ekle',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
