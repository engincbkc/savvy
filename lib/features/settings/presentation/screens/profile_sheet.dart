import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/providers/firebase_providers.dart';

void showProfileSheet(BuildContext context, WidgetRef ref) {
  final user = ref.read(currentUserProvider);
  final nameController =
      TextEditingController(text: user?.displayName ?? '');

  showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final c = AppColors.of(ctx);
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
                    color: c.borderDefault.withValues(alpha: 0.4),
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Profili Düzenle',
                style: AppTypography.headlineSmall.copyWith(
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: c.surfaceOverlay,
                  borderRadius: AppRadius.input,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.brandPrimary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.chip,
                      ),
                      child: Icon(
                        Icons.email_rounded,
                        size: 18,
                        color: c.brandPrimary,
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
                              color: c.textTertiary,
                            ),
                          ),
                          Text(
                            user?.email ?? '-',
                            style: AppTypography.bodyMedium.copyWith(
                              color: c.textPrimary,
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
                        color: c.income.withValues(alpha: 0.1),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        'Doğrulanmış',
                        style: AppTypography.labelSmall.copyWith(
                          color: c.income,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              TextFormField(
                controller: nameController,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Görünen İsim',
                  hintStyle: TextStyle(color: c.textTertiary),
                  prefixIcon: Icon(AppIcons.person, size: 20, color: c.textTertiary),
                  filled: true,
                  fillColor: c.surfaceOverlay,
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
                    borderSide: BorderSide(
                      color: c.brandPrimary,
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
                  if (ctx.mounted) Navigator.of(ctx, rootNavigator: true).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profil güncellendi'),
                        backgroundColor: c.income,
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
      );
    },
  );
}
