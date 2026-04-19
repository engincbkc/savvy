import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/settings/presentation/widgets/settings_shared_widgets.dart';

// ─── Privacy Info ──────────────────────────────────────────────────────────

void showPrivacyInfo(BuildContext context) {
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = AppColors.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: c.surfaceCard,
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
                    color: c.borderDefault.withValues(alpha: 0.4),
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.brandPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.shieldCheck,
                  color: c.brandPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Gizlilik & Güvenlik',
                style: AppTypography.headlineSmall.copyWith(
                  color: c.textPrimary,
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
      );
    },
  );
}

// ─── About ──────────────────────────────────────────────────────────────────

void showAbout(BuildContext context) {
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = AppColors.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: c.surfaceCard,
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
                    color: c.borderDefault.withValues(alpha: 0.4),
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
                  color: c.brandPrimary,
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
                  color: c.surfaceOverlay,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'v1.0.0',
                  style: AppTypography.labelSmall.copyWith(
                    color: c.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Kişisel finans takip uygulamanız.\nGelir, gider ve birikimlerinizi kolayca yönetin.',
                style: AppTypography.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Privacy Policy & Terms links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://savvy.com.tr/privacy'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      'Gizlilik Politikası',
                      style: AppTypography.labelSmall.copyWith(
                        color: c.brandPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: c.brandPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '·',
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => launchUrl(
                      Uri.parse('https://savvy.com.tr/terms'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(
                      'Kullanım Şartları',
                      style: AppTypography.labelSmall.copyWith(
                        color: c.brandPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: c.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '© 2026 Savvy',
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      );
    },
  );
}

// ─── Logout Confirmation ────────────────────────────────────────────────────

void confirmLogout(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = AppColors.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: c.surfaceCard,
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
                    color: c.borderDefault.withValues(alpha: 0.4),
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.expense.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.logout,
                  color: c.expense,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Çıkış Yap',
                style: AppTypography.headlineSmall.copyWith(
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
                style: AppTypography.bodyMedium.copyWith(
                  color: c.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(ctx, rootNavigator: true).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.base,
                        ),
                        side: BorderSide(
                          color: c.borderDefault,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.input,
                        ),
                      ),
                      child: Text(
                        'İptal',
                        style: AppTypography.labelLarge.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(ctx, rootNavigator: true).pop();
                        try {
                          await GoogleSignIn.instance.disconnect();
                        } catch (_) {}
                        await FirebaseAuth.instance.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.expense,
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
      );
    },
  );
}
