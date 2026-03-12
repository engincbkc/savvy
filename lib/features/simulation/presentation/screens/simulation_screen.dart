import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/shared/widgets/empty_state.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simülasyon',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: EmptyState(
        icon: AppIcons.simulate,
        title: 'Finansal Simülasyon',
        subtitle:
            'Kredi, kira artışı veya araç alımı simülasyonu yaparak büyük kararlarını önceden test et.',
        actionLabel: 'Simülasyon Başlat',
        onAction: () {},
      ),
    );
  }
}
