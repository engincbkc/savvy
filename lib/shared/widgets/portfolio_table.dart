import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

// ═══════════════════════════════════════════════════════════════════
// Data Model
// ═══════════════════════════════════════════════════════════════════

class PortfolioRow {
  final String id;
  final String title;
  final String? subtitle;
  final double amount;
  final DateTime date;
  final IconData icon;
  final Color accentColor;
  final bool isRecurring;
  /// Extra columns: label → value
  final Map<String, String> extraColumns;

  const PortfolioRow({
    required this.id,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.date,
    required this.icon,
    required this.accentColor,
    this.isRecurring = false,
    this.extraColumns = const {},
  });
}

class PortfolioAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const PortfolioAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Collapsible Portfolio Table
// ═══════════════════════════════════════════════════════════════════

class PortfolioTable extends StatefulWidget {
  final String title;
  final IconData titleIcon;
  final Color color;
  final List<PortfolioRow> rows;
  final List<String> columnHeaders;
  /// Build extra column values for a row. Returns list matching columnHeaders length.
  final List<String> Function(PortfolioRow row)? buildColumns;
  /// Actions shown when tapping a row
  final List<PortfolioAction> Function(PortfolioRow row)? buildActions;
  final bool initiallyExpanded;

  const PortfolioTable({
    super.key,
    required this.title,
    required this.titleIcon,
    required this.color,
    required this.rows,
    this.columnHeaders = const ['TUTAR'],
    this.buildColumns,
    this.buildActions,
    this.initiallyExpanded = true,
  });

  @override
  State<PortfolioTable> createState() => _PortfolioTableState();
}

class _PortfolioTableState extends State<PortfolioTable>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  String? _selectedRowId;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: c.borderDefault.withValues(alpha: 0.4),
        ),
        boxShadow: AppShadow.xs,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header (tappable to expand/collapse) ──
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? widget.color.withValues(alpha: 0.06)
                    : widget.color.withValues(alpha: 0.03),
                border: Border(
                  bottom: BorderSide(
                    color: c.borderDefault.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(widget.titleIcon, size: 16, color: widget.color),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      '${widget.rows.length}',
                      style: AppTypography.caption.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Total
                  Text(
                    CurrencyFormatter.formatNoDecimal(
                      widget.rows.fold(0.0, (s, r) => s + r.amount),
                    ),
                    style: AppTypography.numericSmall.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: _expanded ? 0.0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: c.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Column headers ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                // Column header row
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.02)
                        : Colors.black.withValues(alpha: 0.02),
                  ),
                  child: Row(
                    children: [
                      // Name column
                      const SizedBox(width: 4 + 8), // accent bar + gap
                      Expanded(
                        flex: 3,
                        child: Text(
                          'KALEM',
                          style: AppTypography.caption.copyWith(
                            color: c.textTertiary,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Dynamic columns
                      ...widget.columnHeaders.map((h) => Expanded(
                            flex: 2,
                            child: Text(
                              h,
                              textAlign: TextAlign.right,
                              style: AppTypography.caption.copyWith(
                                color: c.textTertiary,
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),

                // ── Data rows ──
                ...widget.rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final isSelected = _selectedRowId == row.id;
                  final isEven = index.isEven;

                  return Column(
                    children: [
                      _PortfolioRowTile(
                        row: row,
                        columnHeaders: widget.columnHeaders,
                        buildColumns: widget.buildColumns,
                        isSelected: isSelected,
                        isEven: isEven,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedRowId =
                                isSelected ? null : row.id;
                          });
                        },
                      ),
                      // Actions popup
                      if (isSelected && widget.buildActions != null)
                        _ActionBar(
                          actions: widget.buildActions!(row),
                          color: widget.color,
                          onDismiss: () =>
                              setState(() => _selectedRowId = null),
                        ),
                    ],
                  );
                }),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Individual Row
// ═══════════════════════════════════════════════════════════════════

class _PortfolioRowTile extends StatelessWidget {
  final PortfolioRow row;
  final List<String> columnHeaders;
  final List<String> Function(PortfolioRow)? buildColumns;
  final bool isSelected;
  final bool isEven;
  final VoidCallback onTap;

  const _PortfolioRowTile({
    required this.row,
    required this.columnHeaders,
    this.buildColumns,
    required this.isSelected,
    required this.isEven,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final columns = buildColumns?.call(row) ??
        [CurrencyFormatter.formatNoDecimal(row.amount)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? row.accentColor.withValues(alpha: 0.06)
              : isEven
                  ? Colors.transparent
                  : c.surfaceOverlay.withValues(alpha: 0.3),
          border: Border(
            bottom: BorderSide(
              color: c.borderDefault.withValues(alpha: 0.15),
            ),
          ),
        ),
        child: Row(
          children: [
            // Accent bar
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: row.accentColor,
                borderRadius: AppRadius.pill,
              ),
            ),
            const SizedBox(width: 8),

            // Name + subtitle
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          row.title.toUpperCase(),
                          style: AppTypography.labelMedium.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (row.isRecurring) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.sync_rounded,
                            size: 10, color: row.accentColor),
                      ],
                    ],
                  ),
                  if (row.subtitle != null)
                    Text(
                      row.subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: c.textTertiary,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Dynamic value columns
            ...columns.asMap().entries.map((e) {
              final val = e.value;
              final isNegative = val.startsWith('-');
              return Expanded(
                flex: 2,
                child: Text(
                  val,
                  textAlign: TextAlign.right,
                  style: AppTypography.numericSmall.copyWith(
                    color: isNegative ? c.expense : row.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Action Bar (popup when row is tapped)
// ═══════════════════════════════════════════════════════════════════

class _ActionBar extends StatelessWidget {
  final List<PortfolioAction> actions;
  final Color color;
  final VoidCallback onDismiss;

  const _ActionBar({
    required this.actions,
    required this.color,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.xs,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? c.surfaceCard.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: AppRadius.card,
              border: Border.all(
                color: c.borderDefault.withValues(alpha: 0.3),
              ),
              boxShadow: AppShadow.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions.map((action) {
                final actionColor = action.color ?? color;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDismiss();
                    action.onTap();
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: actionColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          action.icon,
                          size: 18,
                          color: actionColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.label,
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
