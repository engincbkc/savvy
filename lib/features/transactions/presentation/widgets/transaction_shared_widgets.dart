import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

// ─── Ay Seçici Chip ─────────────────────────────────────────────────────

class MonthChip extends StatelessWidget {
  final String label;
  final String? year;
  final bool isSelected;
  final VoidCallback onTap;

  const MonthChip({
    super.key,
    required this.label,
    this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : AppColors.surfaceOverlay,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isSelected
                ? AppColors.brandPrimary
                : AppColors.borderDefault.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              year != null ? '$label \'${year!.substring(2)}' : label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Summary ──────────────────────────────────────────────────────

class QuickSummaryChip extends StatelessWidget {
  final double net;
  const QuickSummaryChip({super.key, required this.net});

  @override
  Widget build(BuildContext context) {
    final isPositive = net >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: isPositive ? AppColors.incomeSurface : AppColors.expenseSurface,
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: isPositive
              ? AppColors.income.withValues(alpha: 0.3)
              : AppColors.expense.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? AppIcons.income : AppIcons.expense,
            size: 14,
            color: isPositive ? AppColors.income : AppColors.expense,
          ),
          const SizedBox(width: 4),
          Text(
            'Net: ${isPositive ? '+' : ''}${CurrencyFormatter.compact(net)}',
            style: AppTypography.labelSmall.copyWith(
              color: isPositive ? AppColors.incomeStrong : AppColors.expenseStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Data ────────────────────────────────────────────────────────────

class TabData {
  final String label;
  final double total;
  final Color color;
  TabData(this.label, this.total, this.color);
}

// ─── Modern Tab Bar ─────────────────────────────────────────────────────

class ModernTabBar extends StatelessWidget {
  final TabController controller;
  final List<TabData> tabs;

  const ModernTabBar({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceOverlay,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(3),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: AppRadius.input,
          boxShadow: AppShadow.sm,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        tabs: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final isSelected = controller.index == i;
          return Tab(
            child: AnimatedDefaultTextStyle(
              duration: AppDuration.fast,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? tab.color : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(tab.label),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Summary Card ────────────────────────────────────────────────────────

class SummaryCard extends StatelessWidget {
  final String title;
  final double total;
  final Color color;
  final List<Color> gradient;
  final IconData icon;
  final int itemCount;
  final int categoryCount;

  const SummaryCard({
    super.key,
    required this.title,
    required this.total,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.itemCount,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(title,
                  style: AppTypography.titleMedium
                      .copyWith(color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: total),
            duration: AppDuration.countUp,
            curve: AppCurve.decelerate,
            builder: (context, value, _) => Text(
              CurrencyFormatter.formatNoDecimal(value),
              style: AppTypography.numericLarge.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              MiniChip(
                label: '$itemCount işlem',
                bgColor: Colors.white.withValues(alpha: 0.15),
                textColor: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: AppSpacing.sm),
              MiniChip(
                label: '$categoryCount kategori',
                bgColor: Colors.white.withValues(alpha: 0.15),
                textColor: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mini Chip ───────────────────────────────────────────────────────────

class MiniChip extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const MiniChip(
      {super.key,
      required this.label,
      required this.bgColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: AppRadius.pill),
      child: Text(label,
          style: AppTypography.caption
              .copyWith(color: textColor, fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Category Accordion ──────────────────────────────────────────────────

class CategoryAccordion extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final List<Widget> children;

  const CategoryAccordion({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm,
          ),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.chip,
            ),
            child: Icon(AppIcons.analytics, size: 17, color: color),
          ),
          title: Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '$count kategori',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          iconColor: AppColors.textTertiary,
          collapsedIconColor: AppColors.textTertiary,
          children: children,
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const SectionHeader({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: AppTypography.titleSmall.copyWith(
                color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: AppColors.surfaceOverlay, borderRadius: AppRadius.pill),
          child: Text('$count',
              style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ─── Category Row ────────────────────────────────────────────────────────

class CategoryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final double percentage;
  final Color color;
  final int count;

  const CategoryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.input,
        border:
            Border.all(color: AppColors.borderDefault.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.textPrimary)),
                    Text('$count işlem',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(CurrencyFormatter.formatNoDecimal(amount),
                      style: AppTypography.numericSmall
                          .copyWith(color: color, fontWeight: FontWeight.w700)),
                  Text('%${(percentage * 100).toStringAsFixed(1)}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Field Chip ─────────────────────────────────────────────────────

class EditFieldChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const EditFieldChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─── Per-Tab FAB ─────────────────────────────────────────────────────────

class TabFab extends StatelessWidget {
  final int tabIndex;
  final VoidCallback onTap;

  const TabFab({super.key, required this.tabIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final config = switch (tabIndex) {
      0 => (AppColors.income, 'Gelir Ekle'),
      1 => (AppColors.expense, 'Gider Ekle'),
      _ => (AppColors.savings, 'Birikim Ekle'),
    };

    return FloatingActionButton.extended(
      heroTag: 'txn_fab',
      onPressed: onTap,
      backgroundColor: config.$1,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(AppIcons.add, size: 20),
      label: Text(
        config.$2,
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Expense Type Row ────────────────────────────────────────────────────

class ExpenseTypeRow extends StatelessWidget {
  final Map<ExpenseType, double> byType;
  final double total;

  const ExpenseTypeRow({super.key, required this.byType, required this.total});

  @override
  Widget build(BuildContext context) {
    if (byType.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: byType.entries.map((entry) {
        final pct = total > 0 ? (entry.value / total * 100) : 0.0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: AppRadius.pill,
            border: Border.all(
                color: AppColors.borderDefault.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(entry.key.label,
                  style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Text('%${pct.toStringAsFixed(0)}',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.expense, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
