import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';
import 'package:savvy/features/savings_goals/presentation/providers/goals_provider.dart';
import 'package:savvy/features/savings_goals/presentation/widgets/goal_add_sheet.dart';
import 'package:savvy/features/savings_goals/presentation/widgets/goal_card.dart';
import 'package:savvy/features/savings_goals/presentation/widgets/goal_detail_sheet.dart';
import 'package:savvy/features/savings_goals/presentation/widgets/goal_empty_state.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

// ═══════════════════════════════════════════════════════════════════
// Ana Ekran
// ═══════════════════════════════════════════════════════════════════

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(allGoalsProvider);
    final summaries = ref.watch(allMonthSummariesProvider);
    final monthlyNet = summaries.isNotEmpty
        ? summaries.first.totalIncome - summaries.first.totalExpense
        : 0.0;
    final c = AppColors.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.base, AppSpacing.lg, 0),
            child: Row(
              children: [
                Text('Hedeflerim',
                    style: AppTypography.headlineMedium
                        .copyWith(color: c.textPrimary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showAddGoal(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB45309), Color(0xFFD97706)],
                      ),
                      borderRadius: AppRadius.pill,
                      boxShadow: [
                        BoxShadow(
                          color: c.savings.withValues(alpha: 0.3),
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
                        Text('Hedef Ekle',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          Expanded(
            child: goalsAsync.when(
              loading: () => const Padding(
                padding: AppSpacing.screenH,
                child: SavvyShimmer(
                  child: Column(children: [
                    ShimmerBox(height: 180),
                    SizedBox(height: AppSpacing.md),
                    ShimmerBox(height: 180),
                  ]),
                ),
              ),
              error: (_, _) => const Center(child: Text('Hata oluştu')),
              data: (goals) {
                if (goals.isEmpty) {
                  return GoalEmptyState(onAdd: () => _showAddGoal(context));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, 100),
                  itemCount: goals.length,
                  itemBuilder: (context, i) => TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (i * 80)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1 - value)),
                        child: child,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.base),
                      child: GoalCard(
                        goal: goals[i],
                        monthlyNet: monthlyNet,
                        onTap: () => _showDetail(context, ref, goals[i], monthlyNet),
                        onEdit: () => _showEditGoal(context, goals[i]),
                        onDelete: () => _confirmDelete(context, ref, goals[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoal(BuildContext context) {
    showModalBottomSheet(useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(ctx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: const GoalAddSheet(),
      ),
    );
  }

  void _showEditGoal(BuildContext context, SavingsGoal goal) {
    showModalBottomSheet(useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(ctx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: GoalAddSheet(existing: goal),
      ),
    );
  }

  void _showDetail(
      BuildContext context, WidgetRef ref, SavingsGoal goal, double monthlyNet) {
    showModalBottomSheet(useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: AppColors.of(ctx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: GoalDetailSheet(goal: goal, monthlyNet: monthlyNet),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        title: Text('Hedef Sil',
            style: AppTypography.headlineSmall
                .copyWith(color: AppColors.of(context).textPrimary)),
        content: Text('"${goal.title}" hedefini silmek istediğine emin misin?',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal',
                style: TextStyle(color: AppColors.of(context).textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              ref.read(goalsProvider.notifier).deleteGoal(goal.id);
            },
            child:
                Text('Sil', style: TextStyle(color: AppColors.of(context).expense)),
          ),
        ],
      ),
    );
  }
}
