import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double total;
  final Color color;
  final List<Color> gradient;
  final IconData icon;
  final int itemCount;
  final int categoryCount;
  /// Optional insight stats shown below the total.
  /// Each entry: label → value string.
  final List<SummaryInsight> insights;

  const SummaryCard({
    super.key,
    required this.title,
    required this.total,
    required this.color,
    required this.gradient,
    required this.icon,
    required this.itemCount,
    required this.categoryCount,
    this.insights = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          children: [
            // Icon watermark in bottom-right
            Positioned(
              right: -AppSpacing.sm,
              bottom: -AppSpacing.sm,
              child: Icon(
                icon,
                size: 80,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            // Shine line at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
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
                          style: AppTypography.titleMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85))),
                      const Spacer(),
                      // Count badges
                      _CountBadge(label: '$itemCount', sub: 'işlem'),
                      const SizedBox(width: 6),
                      _CountBadge(label: '$categoryCount', sub: 'kat.'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),

                  // Animated total
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: total),
                    duration: AppDuration.countUp,
                    curve: AppCurve.decelerate,
                    builder: (context, value, _) => Text(
                      CurrencyFormatter.formatNoDecimal(value),
                      style: AppTypography.numericLarge
                          .copyWith(color: Colors.white, fontSize: 32),
                    ),
                  ),

                  // Insights grid
                  if (insights.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: _buildInsightsGrid(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsGrid() {
    // 2 columns layout
    final rows = <Widget>[];
    for (int i = 0; i < insights.length; i += 2) {
      rows.add(Row(
        children: [
          Expanded(child: _InsightTile(insight: insights[i])),
          if (i + 1 < insights.length) ...[
            Container(
              width: 1,
              height: 32,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            Expanded(child: _InsightTile(insight: insights[i + 1])),
          ] else
            const Expanded(child: SizedBox()),
        ],
      ));
      if (i + 2 < insights.length) {
        rows.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ));
      }
    }
    return Column(children: rows);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Insight Data
// ═══════════════════════════════════════════════════════════════════

class SummaryInsight {
  final String label;
  final String value;
  final IconData? icon;
  /// If true, value is shown in green-ish. If false, red-ish. Null = neutral.
  final bool? isPositive;

  const SummaryInsight({
    required this.label,
    required this.value,
    this.icon,
    this.isPositive,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Private Widgets
// ═══════════════════════════════════════════════════════════════════

class _InsightTile extends StatelessWidget {
  final SummaryInsight insight;

  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final valueColor = insight.isPositive == null
        ? Colors.white
        : insight.isPositive!
            ? const Color(0xFFBBF7D0) // light green
            : const Color(0xFFFECACA); // light red

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (insight.icon != null) ...[
                Icon(insight.icon, size: 10,
                    color: Colors.white.withValues(alpha: 0.5)),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  insight.label,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                    fontSize: 9,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            insight.value,
            style: AppTypography.numericSmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String label;
  final String sub;

  const _CountBadge({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.numericSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            sub,
            style: AppTypography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// Backward compat — old MiniChip still used elsewhere
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
