import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

/// Visual variant for [SavvyDialog].
enum SavvyDialogVariant { info, success, warning, destructive }

/// Unified bottom-sheet style dialog for confirms, info, and destructive
/// actions. Use this instead of raw [AlertDialog] / ad-hoc bottom sheets so
/// every modal in the app shares the same visual language.
abstract class SavvyDialog {
  /// Generic confirm/info dialog. Returns [true] if the user pressed the
  /// primary action, [false]/[null] otherwise. When [destructiveLabel] is
  /// provided, an extra red action button is rendered between cancel and
  /// confirm (e.g. "Discard without saving").
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Tamam',
    String? cancelLabel,
    String? destructiveLabel,
    IconData? icon,
    SavvyDialogVariant variant = SavvyDialogVariant.info,
    VoidCallback? onConfirm,
    VoidCallback? onDestructive,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SavvyDialogBody(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructiveLabel: destructiveLabel,
        icon: icon,
        variant: variant,
        onConfirm: onConfirm,
        onDestructive: onDestructive,
      ),
    );
  }

  /// Destructive confirmation (red accent). Calls [onConfirm] when user taps
  /// the primary action.
  static Future<bool?> destructive({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Evet, Sil',
    String cancelLabel = 'Vazgeç',
    IconData icon = LucideIcons.trash2,
    required VoidCallback onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      variant: SavvyDialogVariant.destructive,
      onConfirm: onConfirm,
    );
  }

  /// Three-action dialog (cancel + destructive + primary). Used for
  /// "Unsaved changes" style prompts where the user can cancel, discard, or
  /// save-and-continue.
  static Future<bool?> tripleAction({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required String destructiveLabel,
    String cancelLabel = 'İptal',
    IconData icon = LucideIcons.alertTriangle,
    SavvyDialogVariant variant = SavvyDialogVariant.warning,
    required VoidCallback onConfirm,
    required VoidCallback onDestructive,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructiveLabel: destructiveLabel,
      icon: icon,
      variant: variant,
      onConfirm: onConfirm,
      onDestructive: onDestructive,
    );
  }
}

class _SavvyDialogBody extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final String? destructiveLabel;
  final IconData? icon;
  final SavvyDialogVariant variant;
  final VoidCallback? onConfirm;
  final VoidCallback? onDestructive;

  const _SavvyDialogBody({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructiveLabel,
    required this.icon,
    required this.variant,
    required this.onConfirm,
    required this.onDestructive,
  });

  Color _accent(BuildContext ctx) {
    final c = AppColors.of(ctx);
    return switch (variant) {
      SavvyDialogVariant.info => c.brandPrimary,
      SavvyDialogVariant.success => c.income,
      SavvyDialogVariant.warning => c.savings,
      SavvyDialogVariant.destructive => c.expense,
    };
  }

  IconData _defaultIcon() => switch (variant) {
        SavvyDialogVariant.info => LucideIcons.info,
        SavvyDialogVariant.success => LucideIcons.checkCircle2,
        SavvyDialogVariant.warning => LucideIcons.alertTriangle,
        SavvyDialogVariant.destructive => LucideIcons.trash2,
      };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = _accent(context);
    final iconData = icon ?? _defaultIcon();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.surfaceCard,
          borderRadius: AppRadius.cardLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: accent, size: 26),
            ),
            const SizedBox(height: AppSpacing.base),
            Padding(
              padding: AppSpacing.screenH,
              child: Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: AppSpacing.screenH,
              child: Text(
                message,
                style: AppTypography.bodyMedium
                    .copyWith(color: c.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: AppSpacing.screenH,
              child: destructiveLabel != null
                  ? Column(
                      children: [
                        _DialogButton(
                          label: confirmLabel,
                          bg: accent,
                          fg: Colors.white,
                          onTap: () {
                            Navigator.pop(context, true);
                            HapticFeedback.mediumImpact();
                            onConfirm?.call();
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _DialogButton(
                          label: destructiveLabel!,
                          bg: c.expense.withValues(alpha: 0.08),
                          fg: c.expense,
                          onTap: () {
                            Navigator.pop(context, false);
                            HapticFeedback.mediumImpact();
                            onDestructive?.call();
                          },
                        ),
                        if (cancelLabel != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _DialogButton(
                            label: cancelLabel!,
                            bg: Colors.transparent,
                            fg: c.textTertiary,
                            onTap: () => Navigator.pop(context, false),
                          ),
                        ],
                      ],
                    )
                  : Row(
                      children: [
                        if (cancelLabel != null) ...[
                          Expanded(
                            child: _DialogButton(
                              label: cancelLabel!,
                              bg: c.surfaceOverlay,
                              fg: c.textSecondary,
                              onTap: () => Navigator.pop(context, false),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                        ],
                        Expanded(
                          child: _DialogButton(
                            label: confirmLabel,
                            bg: accent,
                            fg: Colors.white,
                            onTap: () {
                              Navigator.pop(context, true);
                              HapticFeedback.mediumImpact();
                              onConfirm?.call();
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(
                height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: AppRadius.input,
      child: InkWell(
        borderRadius: AppRadius.input,
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
