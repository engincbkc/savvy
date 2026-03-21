import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/providers/firebase_providers.dart';

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    if (hour < 22) return 'İyi akşamlar';
    return 'İyi geceler';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final c = AppColors.of(context);
    final displayName = user?.displayName ?? 'Kullanıcı';
    final firstName = displayName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _greeting(),
            style: AppTypography.bodyMedium.copyWith(
              color: c.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            firstName,
            style: AppTypography.headlineMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
