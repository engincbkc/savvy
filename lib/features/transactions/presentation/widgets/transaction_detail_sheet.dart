import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/features/transactions/presentation/widgets/form_shared_widgets.dart';

class TransactionDetailSheet extends StatelessWidget {
  final String title;
  final String categoryLabel;
  final IconData categoryIcon;
  final double amount;
  final DateTime date;
  final Color color;
  final List<Color> gradient;
  final String? note;
  final String? person;
  final bool isRecurring;
  final DateTime? recurringEndDate;
  final String? extraLabel;
  final String? extraValue;
  final VoidCallback onEdit;

  const TransactionDetailSheet({
    super.key,
    required this.title,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.amount,
    required this.date,
    required this.color,
    required this.gradient,
    this.note,
    this.person,
    this.isRecurring = false,
    this.recurringEndDate,
    this.extraLabel,
    this.extraValue,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          left: AppSpacing.base,
          right: AppSpacing.base,
          top: AppSpacing.sm,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            const SizedBox(height: AppSpacing.lg),

            // Compact hero card with glassmorphism
            ClipRRect(
              borderRadius: AppRadius.cardLg,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        gradient.first.withValues(alpha: 0.85),
                        gradient.last.withValues(alpha: 0.9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.cardLg,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Icon + Category row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Icon(
                              categoryIcon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (person != null && person!.isNotEmpty)
                                Text(
                                  person!,
                                  style: AppTypography.titleSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              else
                                Text(
                                  title,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              Text(
                                categoryLabel,
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Amount
                      Text(
                        CurrencyFormatter.formatNoDecimal(amount),
                        style: AppTypography.numericHero.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            // Details card with clean design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: c.surfaceCard,
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: c.borderDefault.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _DetailItem(
                    icon: LucideIcons.calendar,
                    label: 'Tarih',
                    value: formatDateTR(date),
                    c: c,
                  ),
                  if (isRecurring) ...[
                    _divider(c),
                    _DetailItem(
                      icon: LucideIcons.repeat,
                      label: 'Periyodik',
                      value: recurringEndDate != null
                          ? 'Bitiş: ${formatDateTR(recurringEndDate!)}'
                          : 'Süresiz',
                      c: c,
                      valueColor: color,
                    ),
                  ],
                  if (extraLabel != null && extraValue != null) ...[
                    _divider(c),
                    _DetailItem(
                      icon: LucideIcons.sliders,
                      label: extraLabel!,
                      value: extraValue!,
                      c: c,
                    ),
                  ],
                  if (note != null && note!.isNotEmpty) ...[
                    _divider(c),
                    _DetailItem(
                      icon: LucideIcons.stickyNote,
                      label: 'Not',
                      value: note!,
                      c: c,
                      isMultiLine: true,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _divider(dynamic c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Container(
          height: 1,
          color: c.borderDefault.withValues(alpha: 0.15),
        ),
      );
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final dynamic c;
  final Color? valueColor;
  final bool isMultiLine;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.c,
    this.valueColor,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: c.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: c.textTertiary,
          ),
        ),
        const Spacer(),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: valueColor ?? c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            maxLines: isMultiLine ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
