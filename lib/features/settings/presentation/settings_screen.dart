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
import 'package:savvy/core/providers/wallet_color_provider.dart';
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
                      tileDivider(color: AppColors.of(context).borderDefault.withValues(alpha: 0.3)),
                      _WalletColorTile(ref: ref),
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

          // ─── Mini wallet preview ──────────────────────────────
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
                // Leather grain overlay
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
                // Flap (V-shape)
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
                // Clasp
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
                // SAVVY text
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

          // Selected color label
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

          // ─── Horizontal color strip palette ─────────────────────
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
                                color: c.brandPrimary.withValues(alpha: 0.35),
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

/// Mini flap clipper for the wallet preview in settings.
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
