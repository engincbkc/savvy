import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_shadow.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/firebase_providers.dart';
import 'package:savvy/core/providers/theme_provider.dart';
import 'package:savvy/features/auth/presentation/providers/auth_provider.dart';
import 'package:savvy/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final displayName = user?.displayName ?? 'Kullanıcı';
    final email = user?.email ?? '';
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'S';

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.surfaceBackground,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Ayarlar',
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: false,
          ),

          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.sm),

                // ─── Profile Card ──────────────────────────────────────
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showProfileSheet(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.cardLg,
                      boxShadow: AppShadow.hero,
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: AppTypography.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (email.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: AppRadius.pill,
                                ),
                                child: Text(
                                  'Profili Düzenle',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          AppIcons.forward,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── Preferences Section ───────────────────────────────
                _SectionHeader(title: 'Tercihler'),
                const SizedBox(height: AppSpacing.sm),

                _SettingsCard(
                  children: [
                    _ModernTile(
                      icon: isDark ? AppIcons.darkMode : AppIcons.lightMode,
                      iconColor: const Color(0xFF6366F1),
                      iconBgColor: const Color(0xFF6366F1),
                      title: 'Görünüm',
                      subtitle: isDark ? 'Karanlık Mod' : 'Aydınlık Mod',
                      trailing: _ThemeToggle(
                        isDark: isDark,
                        onChanged: (_) {
                          HapticFeedback.selectionClick();
                          ref.read(themeModeProvider.notifier).toggle();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── Data Section ──────────────────────────────────────
                _SectionHeader(title: 'Veriler'),
                const SizedBox(height: AppSpacing.sm),

                _SettingsCard(
                  children: [
                    _ModernTile(
                      icon: AppIcons.download,
                      iconColor: AppColors.income,
                      iconBgColor: AppColors.income,
                      title: 'Veriyi Dışa Aktar',
                      subtitle: 'CSV formatında paylaş',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _exportData(context, ref);
                      },
                    ),
                    _tileDivider(),
                    _ModernTile(
                      icon: LucideIcons.shield,
                      iconColor: AppColors.brandPrimary,
                      iconBgColor: AppColors.brandPrimary,
                      title: 'Gizlilik & Güvenlik',
                      subtitle: 'Veriler cihazında güvende',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showPrivacyInfo(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── About Section ─────────────────────────────────────
                _SectionHeader(title: 'Uygulama'),
                const SizedBox(height: AppSpacing.sm),

                _SettingsCard(
                  children: [
                    _ModernTile(
                      icon: AppIcons.info,
                      iconColor: AppColors.savings,
                      iconBgColor: AppColors.savings,
                      title: 'Hakkında',
                      subtitle: 'Savvy v1.0.0',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showAbout(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── Logout Button ─────────────────────────────────────
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _confirmLogout(context, ref);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.08),
                      borderRadius: AppRadius.card,
                      border: Border.all(
                        color: AppColors.expense.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          AppIcons.logout,
                          color: AppColors.expense,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Çıkış Yap',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── Footer ────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Savvy',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Finansal özgürlüğün yol arkadaşı',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
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

  // ─── Profile Sheet ──────────────────────────────────────────────────────

  void _showProfileSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final nameController =
        TextEditingController(text: user?.displayName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
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

              // Title
              Text(
                'Profili Düzenle',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Email (read-only)
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOverlay,
                  borderRadius: AppRadius.input,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.chip,
                      ),
                      child: Icon(
                        Icons.email_rounded,
                        size: 18,
                        color: AppColors.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'E-posta',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            user?.email ?? '-',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.1),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        'Doğrulanmış',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.income,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Display name (editable)
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Görünen İsim',
                  prefixIcon: const Icon(AppIcons.person, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceOverlay,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: const BorderSide(
                      color: AppColors.brandPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    await user?.updateDisplayName(newName);
                    ref.invalidate(currentUserProvider);
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profil güncellendi'),
                        backgroundColor: AppColors.income,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.chip,
                        ),
                        margin: const EdgeInsets.all(AppSpacing.base),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Kaydet'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Export Data ────────────────────────────────────────────────────────

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veriler hazırlanıyor...'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
          margin: const EdgeInsets.all(AppSpacing.base),
          duration: const Duration(seconds: 1),
        ),
      );

      final incomes = ref.read(allIncomesProvider).value ?? [];
      final expenses = ref.read(allExpensesProvider).value ?? [];
      final savings = ref.read(allSavingsProvider).value ?? [];

      final rows = <List<String>>[
        ['Tür', 'Tutar', 'Kategori', 'Tarih', 'Not'],
      ];

      for (final i in incomes) {
        rows.add([
          'Gelir',
          i.amount.toStringAsFixed(2),
          i.category.label,
          '${i.date.day.toString().padLeft(2, '0')}.${i.date.month.toString().padLeft(2, '0')}.${i.date.year}',
          i.note ?? '',
        ]);
      }

      for (final e in expenses) {
        rows.add([
          'Gider',
          e.amount.toStringAsFixed(2),
          e.category.label,
          '${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}',
          e.note ?? '',
        ]);
      }

      for (final s in savings) {
        rows.add([
          'Birikim',
          s.amount.toStringAsFixed(2),
          s.category.label,
          '${s.date.day.toString().padLeft(2, '0')}.${s.date.month.toString().padLeft(2, '0')}.${s.date.year}',
          s.note ?? '',
        ]);
      }

      final csvData = const CsvEncoder().convert(rows);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/savvy_veriler.csv');
      await file.writeAsString(csvData);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Savvy - Finansal Verilerim',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dışa aktarma başarısız: $e'),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
            margin: const EdgeInsets.all(AppSpacing.base),
          ),
        );
      }
    }
  }

  // ─── Privacy Info ──────────────────────────────────────────────────────

  void _showPrivacyInfo(BuildContext context) {
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
              _PrivacyItem(
                icon: LucideIcons.lock,
                text: 'Verileriniz Firebase ile şifrelenmiş olarak saklanır',
              ),
              const SizedBox(height: AppSpacing.md),
              _PrivacyItem(
                icon: LucideIcons.eyeOff,
                text: 'Finansal verileriniz üçüncü taraflarla paylaşılmaz',
              ),
              const SizedBox(height: AppSpacing.md),
              _PrivacyItem(
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

  // ─── About ──────────────────────────────────────────────────────────────

  void _showAbout(BuildContext context) {
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

  // ─── Logout ────────────────────────────────────────────────────────────

  void _confirmLogout(BuildContext context, WidgetRef ref) {
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

  Widget _tileDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Divider(
        height: 1,
        color: AppColors.borderDefault.withValues(alpha: 0.3),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Settings Card ───────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

// ─── Modern Tile ─────────────────────────────────────────────────────────────

class _ModernTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ModernTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.chip,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                AppIcons.forward,
                size: 16,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Theme Toggle ────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ThemeToggle({required this.isDark, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isDark),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 56,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: AppRadius.pill,
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF6366F1)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDark ? LucideIcons.moon : LucideIcons.sun,
              size: 14,
              color: isDark ? const Color(0xFF6366F1) : const Color(0xFFF59E0B),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Privacy Item ────────────────────────────────────────────────────────────

class _PrivacyItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PrivacyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.income.withValues(alpha: 0.1),
            borderRadius: AppRadius.chip,
          ),
          child: Icon(icon, size: 18, color: AppColors.income),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
