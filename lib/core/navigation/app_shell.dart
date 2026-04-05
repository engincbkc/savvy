import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/simulate')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: _FloatingNavBar(currentIndex: _currentIndex(context)),
    );
  }
}

// ─── Floating Nav Bar ─────────────────────────────────────────────────────────

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;

  const _FloatingNavBar({required this.currentIndex});

  static const _items = [
    _NavDef(icon: LucideIcons.home, label: 'Ana Sayfa', path: '/dashboard'),
    _NavDef(icon: LucideIcons.wallet, label: 'İşlemler', path: '/transactions'),
    _NavDef(icon: LucideIcons.sparkles, label: 'Simülasyon', path: '/simulate'),
    _NavDef(icon: LucideIcons.settings2, label: 'Ayarlar', path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.cardLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: isDark
                    ? c.surfaceCard.withValues(alpha: 0.90)
                    : c.surfaceCard.withValues(alpha: 0.96),
                borderRadius: AppRadius.cardLg,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.08),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(_items.length, (i) => _NavItem(
                  def: _items[i],
                  isActive: currentIndex == i,
                  onTap: () => context.go(_items[i].path),
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item ────────────────────────────────────────────────────────────────

class _NavDef {
  final IconData icon;
  final String label;
  final String path;
  const _NavDef({required this.icon, required this.label, required this.path});
}

class _NavItem extends StatelessWidget {
  final _NavDef def;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.def,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final brand = c.brandPrimary;
    final muted = c.textTertiary;
    final color = isActive ? brand : muted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context, rootNavigator: true)
              .popUntil((r) => r is! PopupRoute);
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with subtle background when active
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                color: isActive
                    ? brand.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isActive ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(def.icon, size: 18, color: color),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Label — always visible, color animates
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
                letterSpacing: isActive ? -0.1 : 0,
              ),
              child: Text(def.label, maxLines: 1),
            ),
            // Tiny dot indicator
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: isActive ? 14 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: brand,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
