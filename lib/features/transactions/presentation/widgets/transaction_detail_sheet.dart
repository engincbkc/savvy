import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.base,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          const SizedBox(height: AppSpacing.xl),

          // Amount hero
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl2,
                horizontal: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.cardLg,
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(categoryIcon, color: Colors.white, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    CurrencyFormatter.formatNoDecimal(amount),
                    style: AppTypography.numericHero.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      categoryLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: c.surfaceOverlay,
              borderRadius: AppRadius.card,
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tarih',
                  value: formatDateTR(date),
                  color: c,
                ),
                if (person != null && person!.isNotEmpty) ...[
                  _divider(c),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Kisi',
                    value: person!,
                    color: c,
                  ),
                ],
                if (isRecurring) ...[
                  _divider(c),
                  _DetailRow(
                    icon: Icons.repeat_rounded,
                    label: 'Periyodik',
                    value: recurringEndDate != null
                        ? 'Bitis: ${formatDateTR(recurringEndDate!)}'
                        : 'Suresiz',
                    color: c,
                    valueColor: color,
                  ),
                ],
                if (extraLabel != null && extraValue != null) ...[
                  _divider(c),
                  _DetailRow(
                    icon: Icons.tune_rounded,
                    label: extraLabel!,
                    value: extraValue!,
                    color: c,
                  ),
                ],
                if (note != null && note!.isNotEmpty) ...[
                  _divider(c),
                  _DetailRow(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Not',
                    value: note!,
                    color: c,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Edit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                final editCallback = onEdit;
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 300), () {
                  editCallback();
                });
              },
              icon: Icon(Icons.edit_rounded, size: 18, color: color),
              label: Text(
                'Duzenle',
                style: AppTypography.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(dynamic c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Divider(height: 1, color: c.borderDefault.withValues(alpha: 0.3)),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final dynamic color;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.textTertiary),
        const SizedBox(width: AppSpacing.md),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: color.textTertiary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: valueColor ?? color.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
