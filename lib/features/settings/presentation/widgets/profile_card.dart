import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/firebase_providers.dart';
import 'package:savvy/core/providers/wallet_color_provider.dart';
import 'package:savvy/features/settings/presentation/screens/profile_sheet.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final walletColor = ref.watch(walletColorProvider);

    final displayName = user?.displayName ?? 'Kullanıcı';
    final email = user?.email ?? '';
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'S';

    // Dynamic text color based on wallet color luminance
    final brightness = walletColor.base.computeLuminance();
    final textColor = brightness > 0.5 ? Colors.black : Colors.white;
    final secondaryTextColor = textColor.withValues(alpha: 0.7);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showProfileSheet(context, ref);
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: walletColor.base,
          borderRadius: AppRadius.cardLg,
          gradient: LinearGradient(
            colors: [
              walletColor.base,
              Color.lerp(walletColor.base, walletColor.highlight, 0.3)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: walletColor.shadow.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            // Subtle inner shadow effect via outer shadow
            BoxShadow(
              color: walletColor.highlight.withValues(alpha: 0.15),
              blurRadius: 1,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: textColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: AppTypography.headlineMedium.copyWith(
                    color: textColor,
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
                      color: textColor,
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
                        color: secondaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Edit (pencil) icon
            Icon(
              LucideIcons.pencil,
              color: textColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
