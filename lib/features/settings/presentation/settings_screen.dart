import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          _SettingsTile(
            icon: AppIcons.person,
            title: 'Profil',
            subtitle: 'Hesap bilgilerini düzenle',
            onTap: () {},
          ),
          _SettingsTile(
            icon: AppIcons.darkMode,
            title: 'Karanlık Mod',
            subtitle: 'Tema tercihini değiştir',
            trailing: Switch(
              value: false,
              onChanged: (v) {},
            ),
          ),
          _SettingsTile(
            icon: AppIcons.download,
            title: 'Veri Dışa Aktar',
            subtitle: 'Verilerini Excel olarak indir',
            onTap: () {},
          ),
          _SettingsTile(
            icon: AppIcons.info,
            title: 'Hakkında',
            subtitle: 'Savvy v1.0.0',
            onTap: () {},
          ),
          _SettingsTile(
            icon: AppIcons.logout,
            title: 'Çıkış Yap',
            titleColor: AppColors.expense,
            onTap: () {},
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
