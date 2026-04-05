import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/features/simulation/presentation/screens/change_sheets.dart';

/// Bottom sheet that lets user pick a change type.
/// Returns a [ChangeType] — the caller should then open [ChangeEditorSheet].
class ChangeTypePicker extends StatelessWidget {
  const ChangeTypePicker({super.key});

  static const _types = ChangeType.values;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceBackground,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.borderDefault,
              borderRadius: AppRadius.pill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Değişiklik Türü',
                style: AppTypography.titleLarge
                    .copyWith(color: c.textPrimary)),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              itemCount: _types.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final opt = _types[i];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pop(opt);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: c.surfaceCard,
                      borderRadius: AppRadius.card,
                      border: Border.all(
                          color: c.borderDefault.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: opt.color.withValues(alpha: 0.1),
                            borderRadius: AppRadius.chip,
                          ),
                          child:
                              Icon(opt.icon, size: 20, color: opt.color),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(opt.label,
                                  style: AppTypography.labelLarge.copyWith(
                                      color: c.textPrimary)),
                              Text(opt.subtitle,
                                  style: AppTypography.caption.copyWith(
                                      color: c.textTertiary)),
                            ],
                          ),
                        ),
                        Icon(LucideIcons.chevronRight,
                            size: 16, color: c.textTertiary),
                      ],
                    ),
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
