import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İşlemler',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: EmptyState(
        icon: AppIcons.analytics,
        title: 'Henüz işlem yok',
        subtitle: 'İlk gelir veya giderini ekleyerek başla.',
        actionLabel: 'İşlem Ekle',
        onAction: () {},
      ),
    );
  }
}
