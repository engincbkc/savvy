import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/theme_provider.dart';
import 'package:savvy/features/settings/presentation/screens/export_data_sheet.dart';
import 'package:savvy/features/settings/presentation/screens/settings_dialogs.dart';
import 'package:savvy/features/settings/presentation/widgets/profile_card.dart';
import 'package:savvy/features/settings/presentation/widgets/settings_shared_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Premium Header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(
                      LucideIcons.wallet,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Ayarlar',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: AppSpacing.screenH,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.base),

                // ─── Profile Card ──────────────────────────────────────
                _StaggeredEntry(
                  delay: 0,
                  child: const ProfileCard(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── Preferences Section ───────────────────────────────
                _StaggeredEntry(
                  delay: 80,
                  child: SectionHeader(title: 'Tercihler'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 120,
                  child: SettingsCard(
                    children: [
                      ModernTile(
                        icon: isDark ? AppIcons.darkMode : AppIcons.lightMode,
                        iconColor: const Color(0xFF6366F1),
                        iconBgColor: const Color(0xFF6366F1),
                        title: 'Görünüm',
                        subtitle: isDark ? 'Karanlık Mod' : 'Aydınlık Mod',
                        trailing: ThemeToggle(
                          isDark: isDark,
                          onChanged: (_) {
                            HapticFeedback.selectionClick();
                            ref.read(themeModeProvider.notifier).toggle();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── Data Section ──────────────────────────────────────
                _StaggeredEntry(
                  delay: 200,
                  child: SectionHeader(title: 'Veriler'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 240,
                  child: SettingsCard(
                    children: [
                      ModernTile(
                        icon: AppIcons.download,
                        iconColor: AppColors.of(context).income,
                        iconBgColor: AppColors.of(context).income,
                        title: 'Veriyi Dışa Aktar',
                        subtitle: 'CSV formatında paylaş',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          exportData(context, ref);
                        },
                      ),
                      tileDivider(color: AppColors.of(context).borderDefault.withValues(alpha: 0.3)),
                      ModernTile(
                        icon: LucideIcons.shield,
                        iconColor: AppColors.of(context).brandPrimary,
                        iconBgColor: AppColors.of(context).brandPrimary,
                        title: 'Gizlilik & Güvenlik',
                        subtitle: 'Veriler cihazında güvende',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showPrivacyInfo(context);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ─── About Section ─────────────────────────────────────
                _StaggeredEntry(
                  delay: 320,
                  child: SectionHeader(title: 'Uygulama'),
                ),
                const SizedBox(height: AppSpacing.sm),

                _StaggeredEntry(
                  delay: 360,
                  child: SettingsCard(
                    children: [
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

                // ─── Logout Button ─────────────────────────────────────
                _StaggeredEntry(
                  delay: 440,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      confirmLogout(context, ref);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                      decoration: BoxDecoration(
                        color: AppColors.of(context).expense.withValues(alpha: 0.08),
                        borderRadius: AppRadius.card,
                        border: Border.all(
                          color: AppColors.of(context).expense.withValues(alpha: 0.15),
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

                const SizedBox(height: AppSpacing.xl),

                // ─── Footer ────────────────────────────────────────────
                _StaggeredEntry(
                  delay: 500,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Savvy',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.of(context).textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Finansal özgürlüğün yol arkadaşı',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.of(context).textTertiary.withValues(alpha: 0.6),
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
}

/// Staggered entrance animation for settings sections.
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
