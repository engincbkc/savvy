import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/settings/presentation/providers/app_lock_provider.dart';

/// Full-screen lock overlay that requires biometric/PIN authentication
class LockScreen extends ConsumerStatefulWidget {
  final Widget child;

  const LockScreen({super.key, required this.child});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _authFailed = false;

  @override
  void initState() {
    super.initState();
    // Auto-trigger auth on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptAuth();
    });
  }

  Future<void> _attemptAuth() async {
    final success = await ref.read(appLockProvider.notifier).authenticate();
    if (!success && mounted) {
      setState(() => _authFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);

    // If not locked, show the child
    if (!lockState.isLocked) {
      return widget.child;
    }

    // Show lock screen
    final c = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenH,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock icon with animation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          c.brandPrimary,
                          c.brandPrimary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: c.brandPrimary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.lock,
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl2),

                // Title
                Text(
                  'Savvy Kilitli',
                  style: AppTypography.headlineMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                Text(
                  lockState.isAuthenticating
                      ? 'Kimlik doğrulanıyor...'
                      : _authFailed
                          ? 'Tekrar deneyin'
                          : 'Devam etmek için kimliğinizi doğrulayın',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _authFailed ? c.expense : c.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl3),

                // Unlock button
                if (!lockState.isAuthenticating)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _authFailed = false);
                      _attemptAuth();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl2,
                        vertical: AppSpacing.base,
                      ),
                      decoration: BoxDecoration(
                        color: c.brandPrimary,
                        borderRadius: AppRadius.pill,
                        boxShadow: [
                          BoxShadow(
                            color: c.brandPrimary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.fingerprint,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Kilidi Aç',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: c.brandPrimary,
                    ),
                  ),

                const SizedBox(height: AppSpacing.xl3),

                // App branding
                Text(
                  'SAVVY',
                  style: AppTypography.labelSmall.copyWith(
                    color: c.textTertiary.withValues(alpha: 0.5),
                    letterSpacing: 4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
