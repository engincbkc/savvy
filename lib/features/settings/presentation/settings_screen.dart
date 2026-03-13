import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          // Profil
          _SettingsTile(
            icon: AppIcons.person,
            title: 'Profil',
            subtitle: user?.email ?? 'Hesap bilgilerini düzenle',
            onTap: () => _showProfileSheet(context, ref),
          ),

          // Karanlık Mod
          _SettingsTile(
            icon: AppIcons.darkMode,
            title: 'Karanlık Mod',
            subtitle: 'Tema tercihini değiştir',
            trailing: Switch(
              value: isDark,
              activeTrackColor: AppColors.brandPrimary,
              onChanged: (_) {
                ref.read(themeModeProvider.notifier).toggle();
              },
            ),
          ),

          // Veri Dışa Aktar
          _SettingsTile(
            icon: AppIcons.download,
            title: 'Veri Dışa Aktar',
            subtitle: 'Verilerini CSV olarak paylaş',
            onTap: () => _exportData(context, ref),
          ),

          // Hakkında
          _SettingsTile(
            icon: AppIcons.info,
            title: 'Hakkında',
            subtitle: 'Savvy v1.0.0',
            onTap: () => _showAbout(context),
          ),

          // Çıkış Yap
          _SettingsTile(
            icon: AppIcons.logout,
            title: 'Çıkış Yap',
            titleColor: AppColors.expense,
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final nameController =
        TextEditingController(text: user?.displayName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Profil',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Email (read-only)
            TextFormField(
              initialValue: user?.email ?? '-',
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'E-posta',
                prefixIcon: Icon(Icons.email_rounded, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            // Display name (editable)
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'İsim',
                prefixIcon: Icon(AppIcons.person, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await user?.updateDisplayName(newName);
                  ref.invalidate(currentUserProvider);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profil güncellendi'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veriler hazırlanıyor...'),
          duration: Duration(seconds: 1),
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
          ),
        );
      }
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Savvy',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.brandPrimary,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.savings_rounded,
          color: AppColors.textInverse,
          size: 28,
        ),
      ),
      children: [
        const SizedBox(height: AppSpacing.base),
        Text(
          'Kişisel finans takip uygulamanız.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Gelir, gider ve birikimlerinizi kolayca yönetin.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(AppIcons.forward, size: 16, color: AppColors.textTertiary)
              : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      minTileHeight: AppSpacing.minTouchTarget,
    );
  }
}
