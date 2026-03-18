import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';

class SwipeableTransactionTile extends StatelessWidget {
  final String id;
  final String title;
  final String? subtitle;
  final double amount;
  final DateTime date;
  final Color color;
  final IconData icon;
  final String prefix;
  final bool isRecurring;
  final String? person;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const SwipeableTransactionTile({
    super.key,
    required this.id,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.date,
    required this.color,
    required this.icon,
    required this.prefix,
    required this.isRecurring,
    this.person,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    final parts = <String>[dateStr];
    if (person != null && person!.isNotEmpty) parts.add(person!);
    if (subtitle != null && subtitle!.isNotEmpty) parts.add(subtitle!);

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // Dialog kendisi siler
      },
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.of(context).expense,
          borderRadius: AppRadius.chip,
        ),
        child: const Icon(AppIcons.delete, color: Colors.white, size: 20),
      ),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.of(context).surfaceCard,
            borderRadius: AppRadius.chip,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              style: AppTypography.titleSmall
                                  .copyWith(color: AppColors.of(context).textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (isRecurring) ...[
                          const SizedBox(width: 4),
                          Icon(AppIcons.recurring, size: 12, color: color),
                        ],
                      ],
                    ),
                    Text(parts.join(' · '),
                        style: AppTypography.caption
                            .copyWith(color: AppColors.of(context).textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Text(
                '$prefix${CurrencyFormatter.formatNoDecimal(amount)}',
                style: AppTypography.numericSmall
                    .copyWith(color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.of(context).textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
