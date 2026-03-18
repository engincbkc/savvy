import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

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
        color: AppColors.of(context).surfaceInput,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.of(context).borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.of(context).textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(label,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.of(context).textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
