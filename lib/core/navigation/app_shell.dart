import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/transactions/presentation/screens/add_income_sheet.dart';
import 'package:savvy/features/transactions/presentation/screens/add_expense_sheet.dart';
import 'package:savvy/features/transactions/presentation/screens/add_savings_sheet.dart';

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

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: AppColors.of(sheetCtx).surfaceCard,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: sheet,
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.of(ctx).surfaceCard,
          borderRadius: AppRadius.card,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'İşlem Ekle',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.of(ctx).textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: AppSpacing.screenH,
              child: Row(
                children: [
                  Expanded(
                    child: _AddOption(
                      icon: AppIcons.income,
                      label: 'Gelir',
                      color: AppColors.of(ctx).income,
                      gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) _showSheet(context, const AddIncomeSheet());
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _AddOption(
                      icon: AppIcons.expense,
                      label: 'Gider',
                      color: AppColors.of(ctx).expense,
                      gradient: const [Color(0xFFC81E1E), Color(0xFFEF4444)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) _showSheet(context, const AddExpenseSheet());
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _AddOption(
                      icon: AppIcons.savings,
                      label: 'Birikim',
                      color: AppColors.of(ctx).savings,
                      gradient: const [Color(0xFFB45309), Color(0xFFD97706)],
                      onTap: () {
                        Navigator.pop(ctx);
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (context.mounted) _showSheet(context, const AddSavingsSheet());
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: MediaQuery.of(ctx).padding.bottom + AppSpacing.xl),
          ],
        ),
      ),
    );
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
                // Left nav items
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

                // Center FAB
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showAddMenu(context),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.of(context).brandPrimary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            AppIcons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right nav items
                _NavItem(
                  icon: AppIcons.simulate,
                  label: 'Simülasyon',
                  isActive: currentIndex == 2,
                  onTap: () => context.go('/simulate'),
                ),
                _NavItem(
                  icon: AppIcons.settings,
                  label: 'Ayarlar',
                  isActive: currentIndex == 3,
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

class _AddOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _AddOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.input,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
