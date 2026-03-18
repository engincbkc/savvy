import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

/// Shared date formatter for form sheets.
String formatDateTR(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Bottom sheet drag handle.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.of(context).borderDefault,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Animated sheet header with icon and title.
class SheetHeader extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;

  const SheetHeader({
    super.key,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: AppRadius.chip,
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.of(context).textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.of(context).textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Animated amount input field.
class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final Color strongColor;
  final Color bgColor;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.color,
    required this.strongColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.cardLg,
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              'Tutar',
              style: AppTypography.caption.copyWith(
                color: color.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              textInputAction: TextInputAction.next,
              style: AppTypography.numericHero.copyWith(
                color: strongColor,
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTypography.numericHero.copyWith(
                  color: color.withValues(alpha: 0.2),
                  fontSize: 36,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                suffixText: '₺',
                suffixStyle: AppTypography.numericLarge.copyWith(
                  color: color.withValues(alpha: 0.4),
                ),
              ),
              validator: validateAmount,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared field chip used in form sheets (date, end date, etc.)
class FieldChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const FieldChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceInput,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.of(context).borderDefault),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.of(context).textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.of(context).textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared amount validator for form sheets.
String? validateAmount(String? v) {
  if (v == null || v.trim().isEmpty) return 'Tutar giriniz';
  final parsed =
      double.tryParse(v.replaceAll(',', '.').replaceAll(' ', ''));
  if (parsed == null || parsed <= 0) return 'Geçerli bir tutar giriniz';
  if (parsed > 10000000) return 'Maksimum tutar ₺10.000.000';
  return null;
}

/// Parses a Turkish-format amount string to double.
double parseAmount(String text) =>
    double.parse(text.replaceAll(',', '.').replaceAll(' ', ''));

/// Category chip selector with icons and staggered animation.
class CategoryChipSelector<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final IconData Function(T)? iconOf;
  final Color activeColor;
  final ValueChanged<T> onSelected;

  const CategoryChipSelector({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    this.iconOf,
    required this.activeColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: values.asMap().entries.map((entry) {
        final idx = entry.key;
        final cat = entry.value;
        final isSelected = selected == cat;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (idx * 30)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 8 * (1 - value)),
              child: child,
            ),
          ),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(cat);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor
                    : AppColors.of(context).surfaceOverlay,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: isSelected
                      ? activeColor
                      : AppColors.of(context).borderDefault,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (iconOf != null) ...[
                    Icon(
                      iconOf!(cat),
                      size: 14,
                      color: isSelected
                          ? Colors.white
                          : AppColors.of(context).textTertiary,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    labelOf(cat),
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.of(context).textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Shared recurring toggle row.
class RecurringToggle extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const RecurringToggle({
    super.key,
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: value
            ? activeColor.withValues(alpha: 0.08)
            : AppColors.of(context).surfaceOverlay,
        borderRadius: AppRadius.input,
        border: Border.all(
          color: value
              ? activeColor.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: value
                  ? activeColor.withValues(alpha: 0.15)
                  : AppColors.of(context).surfaceInput,
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              Icons.repeat_rounded,
              size: 16,
              color: value ? activeColor : AppColors.of(context).textTertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.titleSmall
                        .copyWith(color: AppColors.of(context).textPrimary)),
                Text(
                  value ? 'Her ay tekrarlanır' : 'Tek seferlik işlem',
                  style: AppTypography.caption.copyWith(
                    color: value ? activeColor : AppColors.of(context).textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Animated submit button with success state.
class FormSubmitButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const FormSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
          elevation: 0,
          shadowColor: color.withValues(alpha: 0.3),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Text(label,
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Success snackbar shown after adding a transaction.
void showSuccessSnackbar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
      margin: const EdgeInsets.all(AppSpacing.base),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Section label for form groups.
class FormSectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;

  const FormSectionLabel({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppColors.of(context).textTertiary),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.of(context).textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
