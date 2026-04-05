import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';
import 'package:savvy/features/savings_goals/domain/models/savings_goal.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';

// Data class for scenario calculations
class GoalScenario {
  final String label;
  final double monthly;
  final int months;
  const GoalScenario({required this.label, required this.monthly, required this.months});
}

class GoalDetailSheet extends StatelessWidget {
  final SavingsGoal goal;
  final double monthlyNet;

  const GoalDetailSheet({super.key, required this.goal, required this.monthlyNet});

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
    final scenarios = <GoalScenario>[];
    if (monthlyNet > 0 && !isCompleted) {
      final m1 = FinancialCalculator.monthsToGoal(
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        monthlySavings: monthlyNet,
      );
      scenarios.add(GoalScenario(
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
      scenarios.add(GoalScenario(
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
      scenarios.add(GoalScenario(
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
          GoalMilestoneBar(progress: progress, color: accentColor),
          const SizedBox(height: AppSpacing.xl),

          // Mini Timeline
          if (!isCompleted && estimatedEnd != null) ...[
            GoalTimelineRow(
              startDate: goal.createdAt,
              currentAmount: goal.currentAmount,
              estimatedEnd: estimatedEnd,
              targetDate: goal.targetDate,
              color: accentColor,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // ─── Akıllı Plan ──────────────────────────────────────────
          if (!isCompleted &&
              goal.targetDate != null &&
              goal.targetAmount > 0) ...[
            _SmartPlanSection(
              goal: goal,
              monthlyNet: monthlyNet,
              accentColor: accentColor,
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
                  child: GoalScenarioRow(scenario: s, color: accentColor),
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

class GoalMilestoneBar extends StatelessWidget {
  final double progress;
  final Color color;
  const GoalMilestoneBar({super.key, required this.progress, required this.color});

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

class GoalTimelineRow extends StatelessWidget {
  final DateTime startDate;
  final double currentAmount;
  final DateTime estimatedEnd;
  final DateTime? targetDate;
  final Color color;

  const GoalTimelineRow({
    super.key,
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
              GoalTimelineDot(color: c.textTertiary, filled: true),
              Expanded(child: Container(height: 2, color: color.withValues(alpha: 0.3))),
              GoalTimelineDot(color: color, filled: true),
              Expanded(
                child: CustomPaint(
                  size: const Size(double.infinity, 2),
                  painter: _DashLinePainter(color: color.withValues(alpha: 0.3)),
                ),
              ),
              GoalTimelineDot(color: color.withValues(alpha: 0.4), filled: false),
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

class GoalTimelineDot extends StatelessWidget {
  final Color color;
  final bool filled;
  const GoalTimelineDot({super.key, required this.color, required this.filled});

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
// Smart Plan Section
// ═══════════════════════════════════════════════════════════════════

class _SmartPlanSection extends StatelessWidget {
  final SavingsGoal goal;
  final double monthlyNet;
  final Color accentColor;

  const _SmartPlanSection({
    required this.goal,
    required this.monthlyNet,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final now = DateTime.now();
    final monthsLeft =
        ((goal.targetDate!.year - now.year) * 12 + goal.targetDate!.month - now.month)
            .clamp(1, 9999);

    final requiredMonthly = FinancialCalculator.requiredMonthlySavings(
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      monthsLeft: monthsLeft,
    );

    final suggested = FinancialCalculator.suggestedMonthlySaving(monthlyNet);
    final monthsWith20 = FinancialCalculator.monthsToGoal(
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      monthlySavings: suggested > 0 ? suggested : 1,
    );
    final arrivalDate = suggested > 0 && monthsWith20 > 0
        ? DateTime(now.year, now.month + monthsWith20, 1)
        : null;

    final isOnTrack = FinancialCalculator.isOnTrackForGoal(
      monthlyNet: monthlyNet,
      requiredMonthly: requiredMonthly,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akıllı Plan',
          style: AppTypography.titleSmall
              .copyWith(color: c.textPrimary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: c.surfaceOverlay,
            borderRadius: AppRadius.card,
            border: Border.all(color: c.borderDefault),
          ),
          child: Column(
            children: [
              // Required monthly row
              _SmartPlanRow(
                label: 'Hedefe Ulaşmak İçin',
                sublabel: 'Aylık Birikim',
                value: requiredMonthly == double.infinity
                    ? '—'
                    : CurrencyFormatter.formatNoDecimal(requiredMonthly),
                valueColor: isOnTrack ? c.income : c.expense,
                icon: isOnTrack
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
              ),
              Divider(height: AppSpacing.xl, color: c.borderDefault),
              // 20% suggestion row
              if (suggested > 0) ...[
                _SmartPlanRow(
                  label: 'Aylık gelirinizin %20\'siyle',
                  sublabel: CurrencyFormatter.formatNoDecimal(suggested),
                  value: monthsWith20 > 0 ? '$monthsWith20 ay' : '—',
                  valueColor: accentColor,
                  icon: Icons.lightbulb_outline_rounded,
                ),
                if (arrivalDate != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.event_rounded, size: 14, color: c.textTertiary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Hedefe ulaşma tarihi: '
                        '${FinancialCalculator.monthNamesTR[arrivalDate.month - 1]} ${arrivalDate.year}',
                        style: AppTypography.caption
                            .copyWith(color: c.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SmartPlanRow extends StatelessWidget {
  final String label;
  final String sublabel;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _SmartPlanRow({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: valueColor),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTypography.labelSmall
                      .copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
              Text(sublabel,
                  style: AppTypography.caption
                      .copyWith(color: c.textTertiary, fontSize: 11)),
            ],
          ),
        ),
        Text(
          value,
          style: AppTypography.numericSmall.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Scenario Row
// ═══════════════════════════════════════════════════════════════════

class GoalScenarioRow extends StatelessWidget {
  final GoalScenario scenario;
  final Color color;
  const GoalScenarioRow({super.key, required this.scenario, required this.color});

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
