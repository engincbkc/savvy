import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';

class GoalsSummary extends StatelessWidget {
  final List<SavingsGoal> goals;

  const GoalsSummary({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();
    final c = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Hedeflerim',
                style: AppTypography.headlineSmall
                    .copyWith(color: c.textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                context.go('/goals');
              },
              child: Text('Tümü',
                  style: AppTypography.labelSmall.copyWith(
                    color: c.brandPrimary,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...goals.take(3).map((goal) {
          final progress = FinancialCalculator.goalProgress(
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => context.go('/goals'),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: c.surfaceCard,
                  borderRadius: AppRadius.input,
                  border: Border.all(
                      color: c.savings.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c.savings.withValues(alpha: 0.1),
                        borderRadius: AppRadius.chip,
                      ),
                      child: Icon(LucideIcons.target,
                          size: 16, color: c.savings),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.title,
                              style: AppTypography.labelMedium.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 6,
                              backgroundColor: c.surfaceOverlay,
                              valueColor: AlwaysStoppedAnimation(
                                  progress >= 1.0
                                      ? c.income
                                      : c.savings),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '%${(progress * 100).toStringAsFixed(0)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: progress >= 1.0
                                ? c.income
                                : c.savings,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatNoDecimal(
                              goal.targetAmount),
                          style: AppTypography.caption.copyWith(
                            color: c.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
