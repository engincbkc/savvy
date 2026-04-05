import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class GoalEmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const GoalEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.savings.withValues(alpha: 0.15),
                  c.savings.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.target, size: 40, color: c.savings),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('İlk Hedefini Oluştur',
              style: AppTypography.headlineSmall
                  .copyWith(color: c.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ev, araba veya hayalindeki tatil için birikim planı yap. '
            'Savvy sana ne kadar sürede ulaşacağını hesaplasın.',
            style: AppTypography.bodyMedium
                .copyWith(color: c.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Quick suggestions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoalSuggestionChip(icon: LucideIcons.home, label: 'Ev', color: c.savings),
              const SizedBox(width: AppSpacing.sm),
              GoalSuggestionChip(icon: LucideIcons.car, label: 'Araba', color: c.savings),
              const SizedBox(width: AppSpacing.sm),
              GoalSuggestionChip(icon: LucideIcons.palmtree, label: 'Tatil', color: c.savings),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.savings,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Hedef Oluştur',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalSuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const GoalSuggestionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
