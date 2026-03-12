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
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) _toggle();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Overlay
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Container(
                  color: Colors.black
                      .withValues(alpha: 0.3 * _controller.value),
                ),
              ),
            ),
          ),

        // Menu items
        ..._buildMenuItems(),

        // Main FAB
        FloatingActionButton(
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
        ),
      ],
    );
  }

  List<Widget> _buildMenuItems() {
    final items = [
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
    ];

    return List.generate(items.length, (i) {
      final delay = i * 0.15;
      final animation = CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, 0.7 + delay, curve: AppCurve.overshoot),
      );
      return Positioned(
        bottom: 80.0 + (i + 1) * 64.0,
        child: ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: _buildMenuItem(items[i]),
          ),
        ),
      );
    });
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
