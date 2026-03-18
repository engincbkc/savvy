import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/auth/presentation/providers/auth_provider.dart';
import 'package:savvy/features/settings/presentation/widgets/settings_shared_widgets.dart';

// ─── Privacy Info ──────────────────────────────────────────────────────────

void showPrivacyInfo(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).padding.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault.withValues(alpha: 0.4),
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.shieldCheck,
                color: AppColors.brandPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Gizlilik & Güvenlik',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            PrivacyItem(
              icon: LucideIcons.lock,
              text: 'Verileriniz Firebase ile şifrelenmiş olarak saklanır',
            ),
            const SizedBox(height: AppSpacing.md),
            PrivacyItem(
              icon: LucideIcons.eyeOff,
              text: 'Finansal verileriniz üçüncü taraflarla paylaşılmaz',
            ),
            const SizedBox(height: AppSpacing.md),
            PrivacyItem(
              icon: LucideIcons.trash2,
              text: 'İstediğiniz zaman verilerinizi silebilirsiniz',
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    ),
  );
}

// ─── About ──────────────────────────────────────────────────────────────────

void showAbout(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).padding.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault.withValues(alpha: 0.4),
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                ),
                borderRadius: AppRadius.cardLg,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.wallet,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Savvy',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.brandPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceOverlay,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                'v1.0.0',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Kişisel finans takip uygulamanız.\nGelir, gider ve birikimlerinizi kolayca yönetin.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '© 2026 Savvy',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    ),
  );
}

// ─── Logout Confirmation ────────────────────────────────────────────────────

void confirmLogout(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(ctx).padding.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault.withValues(alpha: 0.4),
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.logout,
                color: AppColors.expense,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'Çıkış Yap',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.base,
                      ),
                      side: BorderSide(
                        color: AppColors.borderDefault,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.input,
                      ),
                    ),
                    child: Text(
                      'İptal',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.expense,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.base,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.input,
                      ),
                    ),
                    child: Text(
                      'Çıkış Yap',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
