import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_animation.dart';

class FabRadialMenu extends StatefulWidget {
  final VoidCallback onAddIncome;
  final VoidCallback onAddExpense;
  final VoidCallback onAddSavings;

  const FabRadialMenu({
    super.key,
    required this.onAddIncome,
    required this.onAddExpense,
    required this.onAddSavings,
  });

  @override
  State<FabRadialMenu> createState() => _FabRadialMenuState();
}

class _FabRadialMenuState extends State<FabRadialMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDuration.moderate,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    setState(() => _isOpen = true);
    _showOverlay();
    _controller.forward();
  }

  void _close() {
    _controller.reverse().then((_) {
      _removeOverlay();
      if (mounted) setState(() => _isOpen = false);
    });
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _MenuOverlay(
        controller: _controller,
        onClose: _close,
        items: [
          _MenuItem(
            label: 'Gelir',
            color: AppColors.income,
            icon: AppIcons.income,
            onTap: () {
              _close();
              widget.onAddIncome();
            },
          ),
          _MenuItem(
            label: 'Gider',
            color: AppColors.expense,
            icon: AppIcons.expense,
            onTap: () {
              _close();
              widget.onAddExpense();
            },
          ),
          _MenuItem(
            label: 'Birikim',
            color: AppColors.savings,
            icon: AppIcons.savings,
            onTap: () {
              _close();
              widget.onAddSavings();
            },
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'main_fab',
      onPressed: _toggle,
      backgroundColor: AppColors.brandPrimary,
      shape: const CircleBorder(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.rotate(
          angle: _controller.value * math.pi / 4,
          child: const Icon(
            AppIcons.add,
            color: AppColors.textInverse,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onClose;
  final List<_MenuItem> items;

  const _MenuOverlay({
    required this.controller,
    required this.onClose,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // FAB center position: bottomNavHeight + fabSize/2
    final fabBottom = AppSpacing.bottomNavHeight + bottomPadding - AppSpacing.fabSize / 2 + 8;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Full-screen overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) => ColoredBox(
                  color: Colors.black.withValues(alpha: 0.4 * controller.value),
                ),
              ),
            ),
          ),
          // Menu items positioned above FAB
          ...List.generate(items.length, (i) {
            final delay = i * 0.12;
            final end = (0.6 + delay).clamp(0.0, 1.0);
            final animation = CurvedAnimation(
              parent: controller,
              curve: Interval(delay, end, curve: AppCurve.overshoot),
            );
            return Positioned(
              bottom: fabBottom + AppSpacing.fabSize + 12 + i * 60.0,
              left: 0,
              right: 0,
              child: Center(
                child: ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: _buildMenuItem(items[i]),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        item.onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              item.label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: AppSpacing.fabSizeSm,
            height: AppSpacing.fabSizeSm,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(item.icon, color: AppColors.textInverse, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuItem({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });
}
