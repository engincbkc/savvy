import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/notifications/domain/notification_preferences.dart';
import 'package:savvy/features/notifications/presentation/providers/notification_provider.dart';
import 'package:savvy/shared/widgets/loading_shimmer.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: c.surfaceBackground,
      appBar: AppBar(
        backgroundColor: c.surfaceCard,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: c.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Bildirimler',
          style: AppTypography.titleLarge.copyWith(
            color: c.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: prefsAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SavvyShimmer(
            child: Column(
              children: [
                ShimmerBox(height: 64),
                const SizedBox(height: AppSpacing.lg),
                ShimmerBox(height: 120),
                const SizedBox(height: AppSpacing.lg),
                ShimmerBox(height: 120),
              ],
            ),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Ayarlar yüklenemedi',
            style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
          ),
        ),
        data: (prefs) => _NotificationSettingsBody(prefs: prefs),
      ),
    );
  }
}

class _NotificationSettingsBody extends ConsumerWidget {
  final NotificationPreferences prefs;
  const _NotificationSettingsBody({required this.prefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);

    void save(NotificationPreferences updated) {
      HapticFeedback.selectionClick();
      ref.read(notificationPreferencesProvider.notifier).save(updated);
    }

    return ListView(
      padding: AppSpacing.screenH.copyWith(
        top: AppSpacing.lg,
        bottom: 100,
      ),
      children: [
        // ─── Info Banner ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.info, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Bildirimler şu an geliştirme aşamasındadır. Ayarlarınız kaydedilir.',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF92400E),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ─── Hatırlatıcılar Section ───────────────────────────────────────
        _SectionLabel(label: 'Hatırlatıcılar'),
        const SizedBox(height: AppSpacing.sm),

        Container(
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: c.borderDefault.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Taksit Bitişleri switch
              SwitchListTile(
                activeThumbColor: c.brandPrimary,
                activeTrackColor: c.brandPrimary.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                title: Text(
                  'Taksit Bitişleri',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Taksit bitmeden ${prefs.installmentWarningDays} gün önce uyar',
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
                value: prefs.installmentReminders,
                onChanged: (val) =>
                    save(prefs.copyWith(installmentReminders: val)),
              ),

              // Slider — shown only when installmentReminders is enabled
              if (prefs.installmentReminders)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base, 0, AppSpacing.base, AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uyarı süresi',
                            style: AppTypography.caption
                                .copyWith(color: c.textSecondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: c.brandPrimary.withValues(alpha: 0.1),
                              borderRadius: AppRadius.chip,
                            ),
                            child: Text(
                              '${prefs.installmentWarningDays} gün',
                              style: AppTypography.labelSmall.copyWith(
                                color: c.brandPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: c.brandPrimary,
                          thumbColor: c.brandPrimary,
                          inactiveTrackColor:
                              c.brandPrimary.withValues(alpha: 0.15),
                          overlayColor:
                              c.brandPrimary.withValues(alpha: 0.1),
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          min: 15,
                          max: 60,
                          divisions: 3,
                          value: prefs.installmentWarningDays.toDouble(),
                          onChanged: (val) => save(
                            prefs.copyWith(
                              installmentWarningDays: val.round(),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('15 gün',
                              style: AppTypography.caption
                                  .copyWith(color: c.textTertiary)),
                          Text('30 gün',
                              style: AppTypography.caption
                                  .copyWith(color: c.textTertiary)),
                          Text('45 gün',
                              style: AppTypography.caption
                                  .copyWith(color: c.textTertiary)),
                          Text('60 gün',
                              style: AppTypography.caption
                                  .copyWith(color: c.textTertiary)),
                        ],
                      ),
                    ],
                  ),
                ),

              Divider(
                height: 1,
                thickness: 1,
                color: c.borderDefault.withValues(alpha: 0.3),
                indent: AppSpacing.base,
                endIndent: AppSpacing.base,
              ),

              // Bütçe Aşımı switch
              SwitchListTile(
                activeThumbColor: c.brandPrimary,
                activeTrackColor: c.brandPrimary.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                title: Text(
                  'Bütçe Aşımı',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "Limit %80'e yaklaşınca uyar",
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
                value: prefs.budgetAlerts,
                onChanged: (val) =>
                    save(prefs.copyWith(budgetAlerts: val)),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // ─── Özetler Section ──────────────────────────────────────────────
        _SectionLabel(label: 'Özetler'),
        const SizedBox(height: AppSpacing.sm),

        Container(
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: c.borderDefault.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Haftalık Özet
              SwitchListTile(
                activeThumbColor: c.brandPrimary,
                activeTrackColor: c.brandPrimary.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                title: Text(
                  'Haftalık Özet',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Her Pazar akşamı gelir-gider özeti',
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
                value: prefs.weeklyDigest,
                onChanged: (val) =>
                    save(prefs.copyWith(weeklyDigest: val)),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: c.borderDefault.withValues(alpha: 0.3),
                indent: AppSpacing.base,
                endIndent: AppSpacing.base,
              ),

              // Aylık Rapor
              SwitchListTile(
                activeThumbColor: c.brandPrimary,
                activeTrackColor: c.brandPrimary.withValues(alpha: 0.4),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                title: Text(
                  'Aylık Rapor',
                  style: AppTypography.titleMedium.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                subtitle: Text(
                  "Her ayın 1'inde geçen ayın raporu",
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
                value: prefs.monthlyReport,
                onChanged: (val) =>
                    save(prefs.copyWith(monthlyReport: val)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.of(context).brandPrimary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label.toUpperCase(),
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.of(context).textTertiary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
