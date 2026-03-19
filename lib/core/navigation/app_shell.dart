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
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.of(context).surfaceCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
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
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.of(context).brandPrimary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: AppRadius.pill,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.of(context).brandPrimary : AppColors.of(context).textTertiary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isActive ? AppColors.of(context).brandPrimary : AppColors.of(context).textTertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
