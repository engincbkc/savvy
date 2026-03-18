import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class TabFab extends StatelessWidget {
  final int tabIndex;
  final VoidCallback onTap;

  const TabFab({super.key, required this.tabIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final config = switch (tabIndex) {
      0 => (AppColors.of(context).income, 'Gelir Ekle'),
      1 => (AppColors.of(context).expense, 'Gider Ekle'),
      _ => (AppColors.of(context).savings, 'Birikim Ekle'),
    };

    return FloatingActionButton.extended(
      heroTag: 'txn_fab',
      onPressed: onTap,
      backgroundColor: config.$1,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(AppIcons.add, size: 20),
      label: Text(
        config.$2,
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
