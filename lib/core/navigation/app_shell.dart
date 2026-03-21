import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/goals')) return 2;
    if (location.startsWith('/simulate')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.of(context)
                      .surfaceCard
                      .withValues(alpha: 0.85)
                  : AppColors.of(context)
                      .surfaceCard
                      .withValues(alpha: 0.92),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    _NavItem(
                      icon: AppIcons.home,
                      label: 'Ana Sayfa',
                      isActive: currentIndex == 0,
                      onTap: () => context.go('/dashboard'),
                    ),
                    _NavItem(
                      icon: AppIcons.analytics,
                      label: 'İşlemler',
                      isActive: currentIndex == 1,
                      onTap: () => context.go('/transactions'),
                    ),
                    _NavItem(
                      icon: AppIcons.goal,
                      label: 'Hedefler',
                      isActive: currentIndex == 2,
                      onTap: () => context.go('/goals'),
                    ),
                    _NavItem(
                      icon: AppIcons.simulate,
                      label: 'Simülasyon',
                      isActive: currentIndex == 3,
                      onTap: () => context.go('/simulate'),
                    ),
                    _NavItem(
                      icon: AppIcons.settings,
                      label: 'Ayarlar',
                      isActive: currentIndex == 4,
                      onTap: () => context.go('/settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brandColor = AppColors.of(context).brandPrimary;
    final inactiveColor = AppColors.of(context).textTertiary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          // Dismiss any open modals/bottom sheets before navigating
          Navigator.of(context, rootNavigator: true).popUntil((route) => route is! PopupRoute);
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? brandColor.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: AppRadius.pill,
              ),
              child: AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 22,
                  color: isActive ? brandColor : inactiveColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.caption.copyWith(
                color: isActive ? brandColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
