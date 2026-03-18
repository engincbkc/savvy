import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

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
        color: AppColors.of(context).surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.of(context).borderDefault.withValues(alpha: 0.5),
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
              color: AppColors.of(context).textPrimary,
            ),
          ),
          subtitle: Text(
            '$count kategori',
            style: AppTypography.caption.copyWith(
              color: AppColors.of(context).textTertiary,
            ),
          ),
          iconColor: AppColors.of(context).textTertiary,
          collapsedIconColor: AppColors.of(context).textTertiary,
          children: children,
        ),
      ),
    );
  }
}
