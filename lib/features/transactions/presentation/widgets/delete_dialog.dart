import 'package:flutter/material.dart';
import 'package:savvy/shared/widgets/savvy_dialog.dart';

/// Thin wrapper around [SavvyDialog.destructive] kept for source compatibility.
void showDeleteConfirmation({
  required BuildContext context,
  required String type,
  required VoidCallback onConfirm,
}) {
  SavvyDialog.destructive(
    context: context,
    title: '$type Sil',
    message:
        'Bu ${type.toLowerCase()}i silmek istediğine emin misin?\nBu işlem geri alınamaz.',
    onConfirm: onConfirm,
  );
}
