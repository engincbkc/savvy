import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';

class GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final double monthlyNet;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
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
              // On-track status banner when there is a target date
              if (goal.targetDate != null &&
                  requiredMonthly != null &&
                  requiredMonthly != double.infinity &&
                  requiredMonthly > 0) ...[
                _OnTrackBanner(
                  monthlyNet: monthlyNet,
                  requiredMonthly: requiredMonthly,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Row(
                children: [
                  if (monthsNeeded > 0)
                    Expanded(
                      child: GoalInsightChip(
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
                      requiredMonthly > 0 &&
                      goal.targetDate == null)
                    Expanded(
                      child: GoalInsightChip(
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

class _OnTrackBanner extends StatelessWidget {
  final double monthlyNet;
  final double requiredMonthly;

  const _OnTrackBanner({
    required this.monthlyNet,
    required this.requiredMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isOnTrack = monthlyNet >= requiredMonthly;
    final color = isOnTrack ? c.income : c.expense;
    final icon = isOnTrack ? LucideIcons.checkCircle2 : LucideIcons.alertCircle;
    final label = isOnTrack
        ? 'Hedefe zamanında ulaşacaksınız'
        : 'Gerekli: ${CurrencyFormatter.formatNoDecimal(requiredMonthly)}/ay';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.input,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class GoalInsightChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const GoalInsightChip({
    super.key,
    required this.icon,
    required this.text,
    required this.color,
  });

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
