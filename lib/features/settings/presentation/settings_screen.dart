import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/theme_provider.dart';
import 'package:savvy/core/providers/wallet_color_provider.dart';
import 'package:savvy/features/settings/presentation/screens/export_data_sheet.dart';
import 'package:savvy/features/settings/presentation/screens/settings_dialogs.dart';
import 'package:savvy/features/settings/presentation/widgets/profile_card.dart';
import 'package:savvy/features/settings/presentation/widgets/settings_shared_widgets.dart';
import 'package:savvy/features/settings/presentation/providers/security_provider.dart';
import 'dart:io' show Platform;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final security = ref.watch(securitySettingsProvider);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Minimal Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'Ayarlar',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.base),

                // ─── 4.1 Profile Card ─────────────────────────────────
                _StaggeredEntry(
                  delay: 0,
                  child: const ProfileCard(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── 4.2 ARAÇLAR ──────────────────────────────────────
                _StaggeredEntry(
                  delay: 60,
                  child: SectionHeader(title: 'Araçlar'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 80,
                  child: SettingsCard(
                    children: [
                      ModernTile(
                        icon: LucideIcons.creditCard,
                        iconColor: AppColors.of(context).expense,
                        iconBgColor: AppColors.of(context).expense,
                        title: 'Borç Takibi',
                        subtitle: 'Taksit takvimi ve borçsuz tarih',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/debt');
                        },
                      ),
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      ModernTile(
                        icon: LucideIcons.fileText,
                        iconColor: AppColors.of(context).brandPrimary,
                        iconBgColor: AppColors.of(context).brandPrimary,
                        title: 'Vergi Raporu',
                        subtitle: 'Yıllık brüt→net vergi özeti',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/settings/tax-report');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── 4.3 TERCİHLER ───────────────────────────────────
                _StaggeredEntry(
                  delay: 100,
                  child: SectionHeader(title: 'Tercihler'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 120,
                  child: SettingsCard(
                    children: [
                      _ThemeSegmentTile(themeMode: themeMode, ref: ref),
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      _WalletColorTile(ref: ref),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── 4.4 GÜVENLİK ────────────────────────────────────
                _StaggeredEntry(
                  delay: 160,
                  child: SectionHeader(title: 'Güvenlik'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 180,
                  child: SettingsCard(
                    children: [
                      ModernTile(
                        icon: LucideIcons.fingerprint,
                        iconColor: const Color(0xFF7E3AF2),
                        iconBgColor: const Color(0xFF7E3AF2),
                        title: 'Uygulama Kilidi',
                        subtitle: security.appLockEnabled
                            ? 'Biyometrik / PIN ile korumalı'
                            : 'Kapalı',
                        trailing: Switch.adaptive(
                          value: security.appLockEnabled,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(securitySettingsProvider.notifier)
                                .setAppLock(val);
                          },
                          activeTrackColor: const Color(0xFF7E3AF2),
                        ),
                      ),
                      if (security.appLockEnabled) ...[
                        tileDivider(
                          color: AppColors.of(context)
                              .borderDefault
                              .withValues(alpha: 0.3),
                        ),
                        _AutoLockTile(
                          currentMinutes: security.autoLockMinutes,
                          onChanged: (minutes) {
                            ref
                                .read(securitySettingsProvider.notifier)
                                .setAutoLockMinutes(minutes);
                          },
                        ),
                      ],
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      ModernTile(
                        icon: LucideIcons.eyeOff,
                        iconColor: const Color(0xFF0E9F6E),
                        iconBgColor: const Color(0xFF0E9F6E),
                        title: 'Ekran Görüntüsü Koruması',
                        subtitle: security.screenshotProtection
                            ? 'Açık — içerik gizleniyor'
                            : 'Kapalı',
                        trailing: Switch.adaptive(
                          value: security.screenshotProtection,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            ref
                                .read(securitySettingsProvider.notifier)
                                .setScreenshotProtection(val);
                          },
                          activeTrackColor: const Color(0xFF0E9F6E),
                        ),
                      ),
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      ModernTile(
                        icon: LucideIcons.shield,
                        iconColor: AppColors.of(context).brandPrimary,
                        iconBgColor: AppColors.of(context).brandPrimary,
                        title: 'Verileriniz nasıl korunuyor?',
                        subtitle: null,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showPrivacyInfo(context);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── 4.5 VERİLER ─────────────────────────────────────
                _StaggeredEntry(
                  delay: 220,
                  child: SectionHeader(title: 'Veriler'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 240,
                  child: SettingsCard(
                    children: [
                      ModernTile(
                        icon: AppIcons.upload,
                        iconColor: AppColors.of(context).brandPrimary,
                        iconBgColor: AppColors.of(context).brandPrimary,
                        title: 'CSV İçe Aktar',
                        subtitle: 'Gelir, gider ve birikim yükle',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/settings/import');
                        },
                      ),
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      ModernTile(
                        icon: AppIcons.download,
                        iconColor: AppColors.of(context).income,
                        iconBgColor: AppColors.of(context).income,
                        title: 'CSV Dışa Aktar',
                        subtitle: 'CSV formatında paylaş',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          exportData(context, ref);
                        },
                      ),
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      ModernTile(
                        icon: LucideIcons.trash2,
                        iconColor: AppColors.of(context).expense,
                        iconBgColor: AppColors.of(context).expense,
                        title: 'Tüm Verileri Sil',
                        subtitle: 'İşlem ve simülasyon verilerini temizle',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _confirmDeleteAllData(context, ref);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── 4.6 UYGULAMA ────────────────────────────────────
                _StaggeredEntry(
                  delay: 300,
                  child: SectionHeader(title: 'Uygulama'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 320,
                  child: SettingsCard(
                    children: [
                      ModernTile(
                        icon: LucideIcons.messageSquare,
                        iconColor: const Color(0xFF3B82F6),
                        iconBgColor: const Color(0xFF3B82F6),
                        title: 'Geri Bildirim',
                        subtitle: 'Bize yazın',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _sendFeedback();
                        },
                      ),
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      ModernTile(
                        icon: LucideIcons.star,
                        iconColor: const Color(0xFFF59E0B),
                        iconBgColor: const Color(0xFFF59E0B),
                        title: 'Uygulamayı Değerlendir',
                        subtitle: 'App Store / Play Store',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _requestReview();
                        },
                      ),
                      tileDivider(
                        color: AppColors.of(context)
                            .borderDefault
                            .withValues(alpha: 0.3),
                      ),
                      ModernTile(
                        icon: AppIcons.info,
                        iconColor: AppColors.of(context).savings,
                        iconBgColor: AppColors.of(context).savings,
                        title: 'Hakkında',
                        subtitle: 'Savvy v1.0.0',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showAbout(context);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── 4.7 Çıkış Yap ──────────────────────────────────
                _StaggeredEntry(
                  delay: 400,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      confirmLogout(context, ref);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.base,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.of(context)
                            .expense
                            .withValues(alpha: 0.08),
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: AppColors.of(context)
                              .expense
                              .withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.logout,
                            color: AppColors.of(context).expense,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Çıkış Yap',
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.of(context).expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ─── Hesabı Sil ──────────────────────────────────────
                _StaggeredEntry(
                  delay: 440,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _confirmDeleteAccount(context, ref);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          'Hesabı Sil',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.of(context).textTertiary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.of(context).textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── Footer ──────────────────────────────────────────
                _StaggeredEntry(
                  delay: 480,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Savvy · v1.0.0',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.of(context).textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Finansal özgürlüğün yol arkadaşı',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.of(context)
                                .textTertiary
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Feedback via email ─────────────────────────────────────────────

  Future<void> _sendFeedback() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfoPlugin = DeviceInfoPlugin();
      String deviceInfo;
      if (Platform.isIOS) {
        final ios = await deviceInfoPlugin.iosInfo;
        deviceInfo = 'iOS ${ios.systemVersion}, ${ios.utsname.machine}';
      } else {
        final android = await deviceInfoPlugin.androidInfo;
        deviceInfo = 'Android ${android.version.release}, ${android.model}';
      }

      final uri = Uri(
        scheme: 'mailto',
        path: 'destek@savvy.com.tr',
        queryParameters: {
          'subject': 'Savvy Geri Bildirim',
          'body': '[Cihaz: $deviceInfo, Uygulama: v${packageInfo.version}]\n\n',
        },
      );
      await launchUrl(uri);
    } catch (_) {}
  }

  // ─── In-app review ─────────────────────────────────────────────────

  Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing();
    }
  }

  // ─── Delete all data ───────────────────────────────────────────────

  void _confirmDeleteAllData(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                        LucideIcons.trash2,
                        color: c.expense,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      'Tüm Verileri Sil',
                      style: AppTypography.headlineSmall.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tüm işlemleriniz, simülasyonlarınız ve borç kayıtlarınız kalıcı olarak silinecek. Hesabınız silinmez. Bu işlem geri alınamaz.',
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
                              side: BorderSide(color: c.borderDefault),
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
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    setSheetState(() => isDeleting = true);
                                    try {
                                      final uid = FirebaseAuth
                                          .instance.currentUser?.uid;
                                      if (uid == null) return;
                                      final fs =
                                          FirebaseFirestore.instance;
                                      final collections = [
                                        'transactions',
                                        'simulations',
                                        'debts',
                                        'periodics',
                                        'incomes',
                                        'expenses',
                                        'savings',
                                      ];
                                      for (final col in collections) {
                                        final snap = await fs
                                            .collection('users')
                                            .doc(uid)
                                            .collection(col)
                                            .get();
                                        for (final doc in snap.docs) {
                                          await doc.reference.delete();
                                        }
                                      }
                                      if (ctx.mounted) {
                                        Navigator.of(ctx,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Tüm veriler silindi'),
                                            backgroundColor: c.income,
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: AppRadius.chip,
                                            ),
                                            margin: const EdgeInsets.all(
                                                AppSpacing.base),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setSheetState(
                                          () => isDeleting = false);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Hata: $e'),
                                            backgroundColor: c.expense,
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: AppRadius.chip,
                                            ),
                                            margin: const EdgeInsets.all(
                                                AppSpacing.base),
                                          ),
                                        );
                                      }
                                    }
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
                            child: isDeleting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Sil',
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
      },
    );
  }

  // ─── Delete account ────────────────────────────────────────────────

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = AppColors.of(ctx);
        bool isDeleting = false;
        String? errorText;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                  bottom:
                      MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
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
                        LucideIcons.userX,
                        color: c.expense,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Text(
                      'Hesabı Sil',
                      style: AppTypography.headlineSmall.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Hesabınızı silmek istediğinizden emin misiniz? Tüm veriler kalıcı olarak silinir.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: c.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(color: c.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'E-posta',
                        hintStyle: TextStyle(color: c.textTertiary),
                        prefixIcon: Icon(Icons.email_rounded,
                            size: 20, color: c.textTertiary),
                        filled: true,
                        fillColor: c.surfaceOverlay,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: TextStyle(color: c.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Şifre',
                        hintStyle: TextStyle(color: c.textTertiary),
                        prefixIcon: Icon(LucideIcons.lock,
                            size: 20, color: c.textTertiary),
                        filled: true,
                        fillColor: c.surfaceOverlay,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.input,
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        errorText!,
                        style: AppTypography.caption.copyWith(
                          color: c.expense,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(ctx, rootNavigator: true)
                                    .pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.base,
                              ),
                              side: BorderSide(color: c.borderDefault),
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
                            onPressed: isDeleting
                                ? null
                                : () async {
                                    setSheetState(() {
                                      isDeleting = true;
                                      errorText = null;
                                    });
                                    try {
                                      final user = FirebaseAuth
                                          .instance.currentUser;
                                      if (user == null) return;

                                      // Re-authenticate
                                      final credential =
                                          EmailAuthProvider.credential(
                                        email:
                                            emailController.text.trim(),
                                        password:
                                            passwordController.text,
                                      );
                                      await user
                                          .reauthenticateWithCredential(
                                              credential);

                                      // Delete Firestore data
                                      final fs =
                                          FirebaseFirestore.instance;
                                      final collections = [
                                        'transactions',
                                        'simulations',
                                        'debts',
                                        'periodics',
                                        'incomes',
                                        'expenses',
                                        'savings',
                                      ];
                                      for (final col in collections) {
                                        final snap = await fs
                                            .collection('users')
                                            .doc(user.uid)
                                            .collection(col)
                                            .get();
                                        for (final doc in snap.docs) {
                                          await doc.reference.delete();
                                        }
                                      }

                                      // Delete auth user
                                      await user.delete();

                                      // Clear local storage
                                      final prefs =
                                          await SharedPreferences
                                              .getInstance();
                                      await prefs.clear();

                                      if (ctx.mounted) {
                                        Navigator.of(ctx,
                                                rootNavigator: true)
                                            .pop();
                                      }
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Hesabınız silindi'),
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  AppRadius.chip,
                                            ),
                                            margin: const EdgeInsets.all(
                                                AppSpacing.base),
                                          ),
                                        );
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      setSheetState(() {
                                        isDeleting = false;
                                        errorText = e.code ==
                                                'wrong-password'
                                            ? 'Şifre yanlış'
                                            : e.code ==
                                                    'invalid-credential'
                                                ? 'Geçersiz bilgiler'
                                                : 'Hata: ${e.message}';
                                      });
                                    } catch (e) {
                                      setSheetState(() {
                                        isDeleting = false;
                                        errorText = 'Hata: $e';
                                      });
                                    }
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
                            child: isDeleting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Hesabı Sil',
                                    style:
                                        AppTypography.labelLarge.copyWith(
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
      },
    );
  }
}

/// Theme segment control tile (Açık / Koyu / Sistem).
class _ThemeSegmentTile extends StatelessWidget {
  final ThemeMode themeMode;
  final WidgetRef ref;

  const _ThemeSegmentTile({required this.themeMode, required this.ref});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isDark = themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              isDark ? AppIcons.darkMode : AppIcons.lightMode,
              size: 18,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Görünüm',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _ThemeSegmentControl(
            current: themeMode,
            onChanged: (mode) {
              HapticFeedback.selectionClick();
              ref.read(themeModeProvider.notifier).setMode(mode);
            },
          ),
        ],
      ),
    );
  }
}

/// 3-segment theme toggle: Açık / Koyu / Sistem
class _ThemeSegmentControl extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSegmentControl({
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceOverlay,
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: c.borderDefault.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentButton(
            label: 'Açık',
            isActive: current == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          _SegmentButton(
            label: 'Koyu',
            isActive: current == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
          _SegmentButton(
            label: 'Sistem',
            isActive: current == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? c.brandPrimary : Colors.transparent,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isActive ? Colors.white : c.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// Auto-lock duration tile.
class _AutoLockTile extends StatelessWidget {
  final int currentMinutes;
  final ValueChanged<int> onChanged;

  const _AutoLockTile({
    required this.currentMinutes,
    required this.onChanged,
  });

  String _label(int minutes) {
    if (minutes == 0) return 'Hemen';
    return '$minutes dakika';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final options = [0, 1, 5, 15];

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          backgroundColor: c.surfaceCard,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.bottomSheet,
          ),
          builder: (ctx) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: c.textTertiary.withValues(alpha: 0.3),
                        borderRadius: AppRadius.pill,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Text(
                      'Otomatik Kilit Süresi',
                      style: AppTypography.titleLarge.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...options.map(
                    (min) => ListTile(
                      title: Text(
                        _label(min),
                        style: AppTypography.bodyLarge.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      trailing: currentMinutes == min
                          ? Icon(Icons.check_rounded,
                              color: c.brandPrimary, size: 20)
                          : null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(min);
                        Navigator.of(ctx, rootNavigator: true).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF7E3AF2).withValues(alpha: 0.1),
                borderRadius: AppRadius.chip,
              ),
              child: const Center(
                child: Icon(LucideIcons.timer, size: 18,
                    color: Color(0xFF7E3AF2)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Otomatik Kilit',
                    style: AppTypography.titleMedium.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _label(currentMinutes),
                    style: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.forward,
              size: 16,
              color: c.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wallet color picker tile for settings.
class _WalletColorTile extends StatelessWidget {
  final WidgetRef ref;
  const _WalletColorTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(walletColorProvider);
    final c = AppColors.of(context);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          useRootNavigator: true,
          context: context,
          backgroundColor: c.surfaceCard,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.bottomSheet,
          ),
          builder: (_) => FractionallySizedBox(
            heightFactor: 0.42,
            child: _WalletColorPicker(
              current: current,
              onSelect: (color) {
                ref.read(walletColorProvider.notifier).set(color);
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: current.base,
                borderRadius: AppRadius.chip,
                border: Border.all(
                  color: current.highlight.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: const Icon(
                LucideIcons.wallet,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cüzdan Rengi',
                    style: AppTypography.titleMedium.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    current.label,
                    style: AppTypography.caption.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              AppIcons.forward,
              size: 16,
              color: c.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet for picking wallet color with preview and circular palette.
class _WalletColorPicker extends StatefulWidget {
  final WalletColor current;
  final ValueChanged<WalletColor> onSelect;

  const _WalletColorPicker({required this.current, required this.onSelect});

  @override
  State<_WalletColorPicker> createState() => _WalletColorPickerState();
}

class _WalletColorPickerState extends State<_WalletColorPicker> {
  late WalletColor _preview;

  @override
  void initState() {
    super.initState();
    _preview = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.textTertiary.withValues(alpha: 0.3),
                borderRadius: AppRadius.pill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Mini wallet preview
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 140,
            height: 90,
            decoration: BoxDecoration(
              color: _preview.base,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _preview.shadow.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _preview.highlight.withValues(alpha: 0.15),
                            Colors.transparent,
                            _preview.base.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: _MiniFlapClipper(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 48,
                      color: Color.lerp(
                        _preview.base,
                        _preview.highlight,
                        0.08,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 8,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _preview.highlight.withValues(alpha: 0.5),
                            _preview.highlight.withValues(alpha: 0.25),
                          ],
                        ),
                        border: Border.all(
                          color: _preview.highlight.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'SAVVY',
                      style: TextStyle(
                        color: _preview.highlight.withValues(alpha: 0.3),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _preview.label,
              key: ValueKey(_preview),
              style: AppTypography.titleSmall.copyWith(
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Horizontal color strip palette
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: WalletColor.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, index) {
                final color = WalletColor.values[index];
                final isSelected = color == _preview;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _preview = color);
                    widget.onSelect(color);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    decoration: BoxDecoration(
                      color: color.base,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? c.brandPrimary
                            : color.highlight.withValues(alpha: 0.15),
                        width: isSelected ? 2.5 : 0.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    c.brandPrimary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniFlapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const r = 14.0;
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.72,
      size.width / 2, size.height,
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.72,
      0, size.height * 0.5,
    );
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StaggeredEntry extends StatelessWidget {
  final int delay;
  final Widget child;

  const _StaggeredEntry({
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final adjusted =
            ((value * (600 + delay) - delay) / 600).clamp(0.0, 1.0);
        return Opacity(
          opacity: adjusted,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - adjusted)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
