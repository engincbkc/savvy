import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';

class TabData {
  final String label;
  final double total;
  final Color color;
  TabData(this.label, this.total, this.color);
}

class ModernTabBar extends StatelessWidget {
  final TabController controller;
  final List<TabData> tabs;

  const ModernTabBar({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceOverlay,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(3),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.of(context).surfaceCard,
          borderRadius: AppRadius.input,
          boxShadow: AppShadow.sm,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        tabs: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final isSelected = controller.index == i;
          return Tab(
            child: AnimatedDefaultTextStyle(
              duration: AppDuration.fast,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? tab.color : AppColors.of(context).textTertiary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(tab.label),
            ),
          );
        }),
      ),
    );
  }
}
