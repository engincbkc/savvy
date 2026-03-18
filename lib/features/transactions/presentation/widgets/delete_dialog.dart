import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

void showDeleteConfirmation({
  required BuildContext context,
  required String type,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      title: Text('$type Sil',
          style: AppTypography.headlineSmall
              .copyWith(color: AppColors.textPrimary)),
      content: Text('Bu ${type.toLowerCase()}i silmek istediğine emin misin?',
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('İptal',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            HapticFeedback.mediumImpact();
            onConfirm();
          },
          child: Text('Sil', style: TextStyle(color: AppColors.expense)),
        ),
      ],
    ),
  );
}
