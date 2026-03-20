import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';

/// Premium salary breakdown panel with glass-effect month strip and
/// animated detailed breakdown. Reusable across income form and simulation.
class SalaryBreakdownPanel extends StatefulWidget {
  final AnnualSalaryBreakdown breakdown;
  final int selectedMonthIndex;
  final ValueChanged<int> onMonthSelected;
  final Color accentColor;

  const SalaryBreakdownPanel({
    super.key,
    required this.breakdown,
    required this.selectedMonthIndex,
    required this.onMonthSelected,
    required this.accentColor,
  });

  @override
  State<SalaryBreakdownPanel> createState() => _SalaryBreakdownPanelState();
}

class _SalaryBreakdownPanelState extends State<SalaryBreakdownPanel>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(SalaryBreakdownPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonthIndex != widget.selectedMonthIndex) {
      _fadeController.forward(from: 0.0);
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    const chipWidth = 78.0;
    final targetOffset =
        (widget.selectedMonthIndex * chipWidth) - (chipWidth * 1.5);
    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = widget.breakdown.months[widget.selectedMonthIndex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  c.surfaceCard,
                  c.surfaceCard.withValues(alpha: 0.8),
                ]
              : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.75),
                ],
        ),
        borderRadius: AppRadius.cardLg,
        border: Border.all(
          color: widget.accentColor.withValues(alpha: isDark ? 0.15 : 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base, AppSpacing.base, AppSpacing.base, 0,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor.withValues(alpha: 0.15),
                        widget.accentColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Icon(
                    Icons.calendar_view_month_rounded,
                    size: 14,
                    color: widget.accentColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '12 Aylık Maaş Dağılımı',
                  style: AppTypography.titleSmall.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                const Spacer(),
                _TaxBracketBadge(
                  rate: selected.taxBracketRate,
                  accentColor: widget.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Month selector strip
          SizedBox(
            height: 80,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = widget.breakdown.months[index];
                final isSelected = index == widget.selectedMonthIndex;
                return _MonthChip(
                  month: month,
                  isSelected: isSelected,
                  accentColor: widget.accentColor,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onMonthSelected(index);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Breakdown detail card
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _fadeController,
              curve: Curves.easeOut,
            ),
            child: _BreakdownDetailCard(
              month: selected,
              accentColor: widget.accentColor,
            ),
          ),

          // Annual summary
          _AnnualSummaryBar(
            breakdown: widget.breakdown,
            accentColor: widget.accentColor,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Month Chip
// ═══════════════════════════════════════════════════════════════════

class _MonthChip extends StatelessWidget {
  final MonthlySalaryDetail month;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _MonthChip({
    required this.month,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bracketColor = taxBracketColor(month.taxBracketRate);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.02)),
          borderRadius: AppRadius.input,
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month.monthShortName,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? accentColor : c.textTertiary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.compact(month.netTakeHome),
              style: AppTypography.numericSmall.copyWith(
                color: isSelected ? accentColor : c.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 16 : 6,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected
                    ? bracketColor
                    : bracketColor.withValues(alpha: 0.3),
                borderRadius: AppRadius.pill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Breakdown Detail Card (Glass Effect)
// ═══════════════════════════════════════════════════════════════════

class _BreakdownDetailCard extends StatelessWidget {
  final MonthlySalaryDetail month;
  final Color accentColor;

  const _BreakdownDetailCard({
    required this.month,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.02),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.5),
                      ],
              ),
              borderRadius: AppRadius.card,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Month title + bracket
                Row(
                  children: [
                    Text(
                      month.monthName,
                      style: AppTypography.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: taxBracketColor(month.taxBracketRate)
                            .withValues(alpha: 0.12),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        'Dilim %${(month.taxBracketRate * 100).toInt()}',
                        style: AppTypography.caption.copyWith(
                          color: taxBracketColor(month.taxBracketRate),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Brüt
                _DetailRow(
                  label: 'Brüt Maaş',
                  value: month.grossMonthly,
                  color: c.textPrimary,
                  isBold: true,
                ),
                const SizedBox(height: 2),
                _DividerLine(color: c.borderDefault),
                const SizedBox(height: 6),

                // Kesintiler
                _DetailRow(
                  label: 'SGK İşçi Payı (%14)',
                  value: -month.sgk,
                  color: c.expense,
                ),
                _DetailRow(
                  label: 'İşsizlik Sigortası (%1)',
                  value: -month.unemploymentInsurance,
                  color: c.expense,
                ),
                _DetailRow(
                  label: 'Gelir Vergisi',
                  value: -month.monthlyIncomeTax,
                  color: c.expense,
                ),
                _DetailRow(
                  label: 'Damga Vergisi',
                  value: -month.stampTax,
                  color: c.expense,
                ),

                const SizedBox(height: 4),

                // İstisnalar
                if (month.gvExemption > 0)
                  _DetailRow(
                    label: 'GV İstisnası',
                    value: month.gvExemption,
                    color: accentColor,
                    prefix: '+',
                  ),
                if (month.stampExemption > 0)
                  _DetailRow(
                    label: 'DV İstisnası',
                    value: month.stampExemption,
                    color: accentColor,
                    prefix: '+',
                  ),

                const SizedBox(height: 6),
                _DividerLine(
                  color: accentColor.withValues(alpha: 0.3),
                  thickness: 1.5,
                ),
                const SizedBox(height: 8),

                // Net ele geçen — hero row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Ele Geçen',
                      style: AppTypography.titleSmall.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: month.netTakeHome),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text(
                        CurrencyFormatter.formatNoDecimal(value),
                        style: AppTypography.numericMedium.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Detail Row
// ═══════════════════════════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isBold;
  final String? prefix;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final displayValue = value.abs();
    final sign = prefix ?? (value < 0 ? '−' : '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isBold ? c.textPrimary : c.textSecondary,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            '$sign${CurrencyFormatter.formatNoDecimal(displayValue)}',
            style: AppTypography.numericSmall.copyWith(
              color: color,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              fontSize: isBold ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Divider Line
// ═══════════════════════════════════════════════════════════════════

class _DividerLine extends StatelessWidget {
  final Color color;
  final double thickness;

  const _DividerLine({required this.color, this.thickness = 0.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Annual Summary Bar
// ═══════════════════════════════════════════════════════════════════

class _AnnualSummaryBar extends StatelessWidget {
  final AnnualSalaryBreakdown breakdown;
  final Color accentColor;

  const _AnnualSummaryBar({
    required this.breakdown,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: Row(
        children: [
          _SummaryChip(
            label: 'Yıllık Net',
            value: CurrencyFormatter.compact(breakdown.totalNet),
            color: accentColor,
            bgColor: accentColor.withValues(alpha: 0.08),
          ),
          const SizedBox(width: AppSpacing.sm),
          _SummaryChip(
            label: 'Eff. Vergi',
            value: '%${(breakdown.effectiveTaxRate * 100).toStringAsFixed(1)}',
            color: c.textSecondary,
            bgColor: c.surfaceOverlay,
          ),
          const SizedBox(width: AppSpacing.sm),
          _SummaryChip(
            label: 'Aralık',
            value:
                '${CurrencyFormatter.compact(breakdown.minNet)}–${CurrencyFormatter.compact(breakdown.maxNet)}',
            color: c.textSecondary,
            bgColor: c.surfaceOverlay,
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.chip,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.of(context).textTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: AppTypography.numericSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tax Bracket Badge
// ═══════════════════════════════════════════════════════════════════

class _TaxBracketBadge extends StatelessWidget {
  final double rate;
  final Color accentColor;

  const _TaxBracketBadge({
    required this.rate,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = taxBracketColor(rate);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '%${(rate * 100).toInt()}',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tax Bracket Color Helper
// ═══════════════════════════════════════════════════════════════════

Color taxBracketColor(double rate) => switch (rate) {
      0.15 => const Color(0xFF10B981),
      0.20 => const Color(0xFF14B8A6),
      0.27 => const Color(0xFFF59E0B),
      0.35 => const Color(0xFFF97316),
      0.40 => const Color(0xFFEF4444),
      _ => const Color(0xFF6B7280),
    };
