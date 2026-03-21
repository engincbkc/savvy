import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';
import 'package:savvy/features/savings_goals/presentation/providers/goals_provider.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';
import 'package:uuid/uuid.dart';

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
                  return _EmptyGoalsState(onAdd: () => _showAddGoal(context));
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
                      child: _GoalCard(
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
        child: const _AddGoalSheet(),
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
        child: _AddGoalSheet(existing: goal),
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
        child: _GoalDetailSheet(goal: goal, monthlyNet: monthlyNet),
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

// ═══════════════════════════════════════════════════════════════════
// Motivasyonel Boş Durum
// ═══════════════════════════════════════════════════════════════════

class _EmptyGoalsState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGoalsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.savings.withValues(alpha: 0.15),
                  c.savings.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.target, size: 40, color: c.savings),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('İlk Hedefini Oluştur',
              style: AppTypography.headlineSmall
                  .copyWith(color: c.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ev, araba veya hayalindeki tatil için birikim planı yap. '
            'Savvy sana ne kadar sürede ulaşacağını hesaplasın.',
            style: AppTypography.bodyMedium
                .copyWith(color: c.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Quick suggestions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SuggestionChip(icon: LucideIcons.home, label: 'Ev', color: c.savings),
              const SizedBox(width: AppSpacing.sm),
              _SuggestionChip(icon: LucideIcons.car, label: 'Araba', color: c.savings),
              const SizedBox(width: AppSpacing.sm),
              _SuggestionChip(icon: LucideIcons.palmtree, label: 'Tatil', color: c.savings),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.savings,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Hedef Oluştur',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SuggestionChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Premium Goal Card
// ═══════════════════════════════════════════════════════════════════

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final double monthlyNet;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.monthlyNet,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final progress = FinancialCalculator.goalProgress(
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
    );
    final remaining = goal.targetAmount - goal.currentAmount;
    final monthsNeeded = monthlyNet > 0
        ? FinancialCalculator.monthsToGoal(
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            monthlySavings: monthlyNet,
          )
        : -1;
    final requiredMonthly = goal.targetDate != null
        ? FinancialCalculator.requiredMonthlySavings(
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            monthsLeft:
                math.max(1, goal.targetDate!.difference(DateTime.now()).inDays ~/ 30),
          )
        : null;
    final isCompleted = progress >= 1.0;
    final accentColor = isCompleted ? c.income : c.savings;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.cardLg,
          border: Border.all(color: c.borderDefault.withValues(alpha: 0.3)),
          boxShadow: AppShadow.sm,
        ),
        child: Column(
          children: [
            // Top row: icon + name + circular progress
            Row(
              children: [
                // Category icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [const Color(0xFF059669), const Color(0xFF10B981)]
                          : [const Color(0xFFB45309), const Color(0xFFD97706)],
                    ),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Icon(goal.category.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                // Title + target date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                          style: AppTypography.titleMedium
                              .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
                      if (goal.targetDate != null)
                        Text(
                          'Hedef: ${formatDateTR(goal.targetDate!)}',
                          style: AppTypography.caption
                              .copyWith(color: c.textTertiary),
                        ),
                    ],
                  ),
                ),
                // Circular progress
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 5,
                          backgroundColor: c.surfaceOverlay,
                          valueColor: AlwaysStoppedAnimation(accentColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '%${(progress * 100).toStringAsFixed(0)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),

            // Amount display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.05),
                borderRadius: AppRadius.input,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${CurrencyFormatter.formatNoDecimal(goal.currentAmount)} / ${CurrencyFormatter.formatNoDecimal(goal.targetAmount)}',
                          style: AppTypography.numericSmall.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCompleted
                              ? 'Hedefe ulaştın!'
                              : '${CurrencyFormatter.formatNoDecimal(remaining)} kaldı',
                          style: AppTypography.caption.copyWith(
                            color: isCompleted ? c.income : c.textTertiary,
                            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.income,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Tamamlandı',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Insights
            if (!isCompleted) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (monthsNeeded > 0)
                    Expanded(
                      child: _InsightChip(
                        icon: LucideIcons.clock,
                        text: 'Bu hızla $monthsNeeded ayda',
                        color: c.brandPrimary,
                      ),
                    ),
                  if (monthsNeeded > 0 &&
                      requiredMonthly != null &&
                      requiredMonthly != double.infinity &&
                      requiredMonthly > 0)
                    const SizedBox(width: AppSpacing.sm),
                  if (requiredMonthly != null &&
                      requiredMonthly != double.infinity &&
                      requiredMonthly > 0)
                    Expanded(
                      child: _InsightChip(
                        icon: LucideIcons.trendingUp,
                        text: 'Aylık ${CurrencyFormatter.formatNoDecimal(requiredMonthly)}',
                        color: c.savings,
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
}

class _InsightChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InsightChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: AppRadius.input,
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Goal Detail Sheet
// ═══════════════════════════════════════════════════════════════════

class _GoalDetailSheet extends StatelessWidget {
  final SavingsGoal goal;
  final double monthlyNet;

  const _GoalDetailSheet({required this.goal, required this.monthlyNet});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final progress = FinancialCalculator.goalProgress(
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
    );
    final remaining = goal.targetAmount - goal.currentAmount;
    final isCompleted = progress >= 1.0;
    final accentColor = isCompleted ? c.income : c.savings;

    // Scenarios
    final scenarios = <_Scenario>[];
    if (monthlyNet > 0 && !isCompleted) {
      final m1 = FinancialCalculator.monthsToGoal(
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        monthlySavings: monthlyNet,
      );
      scenarios.add(_Scenario(
        label: 'Mevcut hız',
        monthly: monthlyNet,
        months: m1,
      ));

      final boosted = monthlyNet * 1.5;
      final m2 = FinancialCalculator.monthsToGoal(
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        monthlySavings: boosted,
      );
      scenarios.add(_Scenario(
        label: '%50 artırırsan',
        monthly: boosted,
        months: m2,
      ));

      final doubled = monthlyNet * 2;
      final m3 = FinancialCalculator.monthsToGoal(
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        monthlySavings: doubled,
      );
      scenarios.add(_Scenario(
        label: '2 katına çıkarırsan',
        monthly: doubled,
        months: m3,
      ));
    }

    // Estimated end date
    final estimatedMonths = monthlyNet > 0
        ? FinancialCalculator.monthsToGoal(
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            monthlySavings: monthlyNet,
          )
        : -1;
    final estimatedEnd = estimatedMonths > 0
        ? DateTime.now().add(Duration(days: estimatedMonths * 30))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.base, AppSpacing.xl, AppSpacing.xl2),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Big circular progress
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 10,
                    backgroundColor: c.surfaceOverlay,
                    valueColor: AlwaysStoppedAnimation(accentColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '%${(progress * 100).toStringAsFixed(1)}',
                      style: AppTypography.numericLarge.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text('tamamlandı',
                        style: AppTypography.caption
                            .copyWith(color: c.textTertiary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Title
          Text(goal.title,
              style: AppTypography.headlineSmall
                  .copyWith(color: c.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${CurrencyFormatter.formatNoDecimal(goal.currentAmount)} / ${CurrencyFormatter.formatNoDecimal(goal.targetAmount)}',
            style: AppTypography.numericMedium.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isCompleted)
            Text('${CurrencyFormatter.formatNoDecimal(remaining)} kaldı',
                style: AppTypography.caption.copyWith(color: c.textTertiary)),
          const SizedBox(height: AppSpacing.xl),

          // Milestones
          _MilestoneBar(progress: progress, color: accentColor),
          const SizedBox(height: AppSpacing.xl),

          // Mini Timeline
          if (!isCompleted && estimatedEnd != null) ...[
            _TimelineRow(
              startDate: goal.createdAt,
              currentAmount: goal.currentAmount,
              estimatedEnd: estimatedEnd,
              targetDate: goal.targetDate,
              color: accentColor,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Scenarios
          if (scenarios.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Senaryolar',
                  style: AppTypography.titleSmall
                      .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppSpacing.md),
            ...scenarios.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ScenarioRow(scenario: s, color: accentColor),
                )),
            const SizedBox(height: AppSpacing.base),
          ],

          // Completed state
          if (isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    c.income.withValues(alpha: 0.1),
                    c.income.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: AppRadius.card,
                border: Border.all(color: c.income.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration_rounded, size: 32, color: c.income),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tebrikler!',
                            style: AppTypography.titleSmall.copyWith(
                              color: c.income,
                              fontWeight: FontWeight.w700,
                            )),
                        Text('Bu hedefe başarıyla ulaştın.',
                            style: AppTypography.caption
                                .copyWith(color: c.textSecondary)),
                      ],
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

// ═══════════════════════════════════════════════════════════════════
// Milestone Bar
// ═══════════════════════════════════════════════════════════════════

class _MilestoneBar extends StatelessWidget {
  final double progress;
  final Color color;
  const _MilestoneBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final milestones = [0.25, 0.50, 0.75, 1.0];

    return Column(
      children: [
        // Bar with milestones
        SizedBox(
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Track
              Positioned(
                left: 0,
                right: 0,
                top: 13,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: c.surfaceOverlay,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              // Fill
              Positioned(
                left: 0,
                top: 13,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FractionallySizedBox(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Milestone dots
              ...milestones.map((m) {
                final reached = progress >= m;
                return Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: m,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: reached ? color : c.surfaceCard,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: reached ? color : c.borderDefault,
                            width: 2,
                          ),
                        ),
                        child: reached
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: milestones.map((m) {
            final reached = progress >= m;
            return Text(
              '%${(m * 100).toInt()}',
              style: AppTypography.caption.copyWith(
                color: reached ? color : c.textTertiary,
                fontWeight: reached ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Timeline Row
// ═══════════════════════════════════════════════════════════════════

class _TimelineRow extends StatelessWidget {
  final DateTime startDate;
  final double currentAmount;
  final DateTime estimatedEnd;
  final DateTime? targetDate;
  final Color color;

  const _TimelineRow({
    required this.startDate,
    required this.currentAmount,
    required this.estimatedEnd,
    this.targetDate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: c.surfaceOverlay,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          // Line with 3 dots
          Row(
            children: [
              _TimelineDot(color: c.textTertiary, filled: true),
              Expanded(child: Container(height: 2, color: color.withValues(alpha: 0.3))),
              _TimelineDot(color: color, filled: true),
              Expanded(
                child: CustomPaint(
                  size: const Size(double.infinity, 2),
                  painter: _DashLinePainter(color: color.withValues(alpha: 0.3)),
                ),
              ),
              _TimelineDot(color: color.withValues(alpha: 0.4), filled: false),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Başlangıç', style: AppTypography.caption.copyWith(color: c.textTertiary, fontSize: 10)),
                  Text(formatDateTR(startDate), style: AppTypography.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600, fontSize: 10)),
                ],
              ),
              Column(
                children: [
                  Text('Şu an', style: AppTypography.caption.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
                  Text(formatDateTR(DateTime.now()), style: AppTypography.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600, fontSize: 10)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(targetDate != null ? 'Hedef' : 'Tahmini', style: AppTypography.caption.copyWith(color: c.textTertiary, fontSize: 10)),
                  Text(formatDateTR(targetDate ?? estimatedEnd), style: AppTypography.caption.copyWith(color: c.textSecondary, fontWeight: FontWeight.w600, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  final Color color;
  final bool filled;
  const _TimelineDot({required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _DashLinePainter extends CustomPainter {
  final Color color;
  _DashLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const dashW = 4.0;
    const gapW = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + dashW, size.height / 2), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════
// Scenario Row
// ═══════════════════════════════════════════════════════════════════

class _Scenario {
  final String label;
  final double monthly;
  final int months;
  const _Scenario({required this.label, required this.monthly, required this.months});
}

class _ScenarioRow extends StatelessWidget {
  final _Scenario scenario;
  final Color color;
  const _ScenarioRow({required this.scenario, required this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.input,
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.chip,
            ),
            child: Icon(LucideIcons.calculator, size: 14, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scenario.label,
                    style: AppTypography.labelSmall
                        .copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                Text(
                  'Aylık ${CurrencyFormatter.formatNoDecimal(scenario.monthly)} biriktirirsen',
                  style: AppTypography.caption.copyWith(color: c.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              scenario.months > 0 ? '${scenario.months} ay' : '—',
              style: AppTypography.labelSmall.copyWith(
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

// ═══════════════════════════════════════════════════════════════════
// Add/Edit Goal Sheet (preserved from before)
// ═══════════════════════════════════════════════════════════════════

class _AddGoalSheet extends ConsumerStatefulWidget {
  final SavingsGoal? existing;
  const _AddGoalSheet({this.existing});

  @override
  ConsumerState<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<_AddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime? _targetDate;
  SavingsCategory _category = SavingsCategory.goal;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final g = widget.existing!;
      _titleController.text = g.title;
      _targetController.text = g.targetAmount.toStringAsFixed(0);
      _currentController.text = g.currentAmount.toStringAsFixed(0);
      _targetDate = g.targetDate;
      _category = g.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final target = parseAmount(_targetController.text);
    final current = _currentController.text.trim().isEmpty
        ? 0.0
        : parseAmount(_currentController.text);

    final goal = _isEdit
        ? widget.existing!.copyWith(
            title: _titleController.text.trim(),
            targetAmount: target,
            currentAmount: current,
            targetDate: _targetDate,
            category: _category,
          )
        : SavingsGoal(
            id: const Uuid().v4(),
            title: _titleController.text.trim(),
            targetAmount: target,
            currentAmount: current,
            targetDate: _targetDate,
            category: _category,
            createdAt: DateTime.now(),
          );

    final notifier = ref.read(goalsProvider.notifier);
    final success =
        _isEdit ? await notifier.updateGoal(goal) : await notifier.addGoal(goal);

    if (mounted && success) {
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.base,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SheetHandle(),
                      const SizedBox(height: AppSpacing.lg),
                      SheetHeader(
                        icon: LucideIcons.target,
                        gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
                        title: _isEdit ? 'Hedef Düzenle' : 'Hedef Ekle',
                        subtitle: _isEdit
                            ? 'Mevcut hedefini güncelle'
                            : 'Yeni bir finansal hedef oluştur',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Hedef adı (ör: Ev alma)',
                          prefixIcon:
                              Icon(LucideIcons.tag, size: 18, color: c.textTertiary),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Hedef adı giriniz' : null,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      AmountInputField(
                        controller: _targetController,
                        color: c.savings,
                        strongColor: c.savingsStrong,
                        bgColor: c.savingsSurfaceDim,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      FormSectionLabel(
                          text: 'Mevcut Birikim', icon: LucideIcons.piggyBank),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _currentController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: false),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                          ThousandFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: '0',
                          suffixText: '₺',
                          prefixIcon:
                              Icon(LucideIcons.coins, size: 18, color: c.textTertiary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      FormSectionLabel(
                          text: 'Hedef Tarihi (opsiyonel)',
                          icon: LucideIcons.calendar),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _targetDate ??
                                DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (picked != null) setState(() => _targetDate = picked);
                        },
                        child: FieldChip(
                          icon: LucideIcons.calendar,
                          label: _targetDate != null
                              ? formatDateTR(_targetDate!)
                              : 'Tarih seç',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      FormSectionLabel(
                          text: 'Kategori', icon: LucideIcons.layoutGrid),
                      const SizedBox(height: AppSpacing.sm),
                      CategoryChipSelector<SavingsCategory>(
                        values: SavingsCategory.values,
                        selected: _category,
                        labelOf: (c) => c.label,
                        iconOf: (c) => c.icon,
                        activeColor: c.savings,
                        onSelected: (cat) => setState(() => _category = cat),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              // Sabit buton — her zaman altta görünür
              FormSubmitButton(
                isLoading: ref.watch(goalsProvider).isLoading,
                label: _isEdit ? 'Kaydet' : 'Hedef Oluştur',
                color: c.savings,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
