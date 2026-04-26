import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/utils/currency_formatter.dart';
import 'package:savvy/core/utils/financial_calculator.dart';

export 'form_validators.dart';
export 'form_duration_picker.dart';

import 'form_validators.dart';

/// Modern glassmorphism date picker bottom sheet.
/// Returns selected [DateTime] or null if dismissed.
Future<DateTime?> showSavvyDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final first = firstDate ?? DateTime(2015);
  final last = lastDate ?? DateTime.now().add(const Duration(days: 366));
  DateTime tempDate = initialDate;

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      final c = AppColors.of(ctx);
      final isDark = Theme.of(ctx).brightness == Brightness.dark;

      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return ClipRRect(
            borderRadius: AppRadius.bottomSheet,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? c.surfaceCard.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: AppRadius.bottomSheet,
                  border: Border.all(
                    color: c.borderDefault.withValues(alpha: 0.2),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: c.borderDefault,
                          borderRadius: AppRadius.pill,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_month_rounded,
                                size: 20, color: c.brandPrimary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'Tarih Seçin',
                              style: AppTypography.titleMedium.copyWith(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            // Selected date preview
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    c.brandPrimary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.pill,
                              ),
                              child: Text(
                                formatDateTR(tempDate),
                                style: AppTypography.labelMedium.copyWith(
                                  color: c.brandPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),

                      // Cupertino date picker
                      SizedBox(
                        height: 220,
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            brightness: isDark
                                ? Brightness.dark
                                : Brightness.light,
                            primaryColor: c.brandPrimary,
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle:
                                  AppTypography.titleMedium.copyWith(
                                color: c.textPrimary,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: initialDate.isBefore(first)
                                ? first
                                : initialDate.isAfter(last)
                                    ? last
                                    : initialDate,
                            minimumDate: first,
                            maximumDate: last,
                            use24hFormat: true,
                            onDateTimeChanged: (date) {
                              setModalState(() => tempDate = date);
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.base),

                      // Confirm button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(ctx, tempDate);
                            },
                            child: const Text('Seç'),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
                // Subtle shine line at top
                Positioned(
                  top: 0,
                  left: 4,
                  right: 4,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
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

/// Premium animated amount input field with glassmorphism effect.
class AmountInputField extends StatefulWidget {
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
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasValue = widget.controller.text.isNotEmpty;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.96, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardLg,
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.color
                            .withValues(alpha: 0.15 + (_glowAnimation.value * 0.1)),
                        blurRadius: 20 + (_glowAnimation.value * 8),
                        spreadRadius: -2,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: c.shadowColor.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: AppRadius.cardLg,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.bgColor,
                    widget.bgColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: AppRadius.cardLg,
                border: Border.all(
                  color: _isFocused
                      ? widget.color.withValues(alpha: 0.4)
                      : widget.color.withValues(alpha: 0.08),
                  width: _isFocused ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  // Currency row with animated indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _isFocused || hasValue
                              ? widget.color.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '₺',
                              style: AppTypography.titleLarge.copyWith(
                                color: widget.color.withValues(
                                    alpha: _isFocused || hasValue ? 0.9 : 0.4),
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'TRY',
                              style: AppTypography.caption.copyWith(
                                color: widget.color.withValues(
                                    alpha: _isFocused || hasValue ? 0.7 : 0.3),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Amount input
                  TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                      ThousandFormatter(),
                    ],
                    textInputAction: TextInputAction.next,
                    style: AppTypography.numericHero.copyWith(
                      color: widget.strongColor,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                    cursorColor: widget.color,
                    cursorWidth: 2.5,
                    cursorRadius: const Radius.circular(2),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppTypography.numericHero.copyWith(
                        color: widget.color.withValues(alpha: 0.15),
                        fontSize: 44,
                        fontWeight: FontWeight.w300,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    validator: validateAmount,
                  ),

                  // Subtle divider line
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    height: 2,
                    width: _isFocused ? 120 : 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withValues(alpha: 0.0),
                          widget.color.withValues(alpha: _isFocused ? 0.5 : 0.2),
                          widget.color.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: AppRadius.pill,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  final bool enabled;

  const FormSubmitButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.color,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || !enabled;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
          elevation: 0,
          shadowColor: Colors.transparent,
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

// ═══════════════════════════════════════════════════════════════════
// Brüt Maaş — Shared Premium Components
// ═══════════════════════════════════════════════════════════════════

/// Premium gross salary amount input with gradient card and animated entrance.
class GrossAmountInput extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final Color strongColor;
  final Color bgColor;

  const GrossAmountInput({
    super.key,
    required this.controller,
    required this.accentColor,
    required this.strongColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              bgColor,
              isDark
                  ? accentColor.withValues(alpha: 0.08)
                  : accentColor.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: AppRadius.cardLg,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_rounded,
                  size: 14,
                  color: accentColor.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'BRÜT MAAŞ',
                  style: AppTypography.caption.copyWith(
                    color: accentColor.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ThousandFormatter(),
              ],
              textInputAction: TextInputAction.done,
              style: AppTypography.numericHero.copyWith(
                color: strongColor,
                fontSize: 36,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: AppTypography.numericHero.copyWith(
                  color: accentColor.withValues(alpha: 0.2),
                  fontSize: 36,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                suffixText: '₺',
                suffixStyle: AppTypography.numericLarge.copyWith(
                  color: accentColor.withValues(alpha: 0.4),
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

/// Toggle switch for brüt→net calculation mode.
/// Styled consistently with SavingsToggle (card radius, custom toggle knob).
class GrossCalcToggle extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const GrossCalcToggle({
    super.key,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: value
              ? activeColor.withValues(alpha: 0.08)
              : c.surfaceCard,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: value
                ? activeColor.withValues(alpha: 0.4)
                : c.borderDefault,
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
                    : c.surfaceInput,
                borderRadius: AppRadius.chip,
              ),
              child: Icon(
                Icons.calculate_rounded,
                size: 16,
                color: value ? activeColor : c.textTertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Brütten Hesapla',
                      style: AppTypography.labelMedium.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(
                    value
                        ? 'SGK, vergi ve istisnalar otomatik hesaplanır'
                        : 'Brüt maaş girip aylık net tutarı gör',
                    style: AppTypography.caption.copyWith(
                      color: value ? activeColor : c.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Custom toggle matching SavingsToggle
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: value ? activeColor : c.surfaceOverlay,
                borderRadius: AppRadius.pill,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info card shown when gross calculation is active — single record hint.
class GrossIncomeInfo extends StatelessWidget {
  final AnnualSalaryBreakdown breakdown;
  final int currentMonth; // 1-indexed
  final Color accentColor;

  const GrossIncomeInfo({
    super.key,
    required this.breakdown,
    required this.currentMonth,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final monthDetail = breakdown.months[(currentMonth - 1).clamp(0, 11)];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: AppRadius.input,
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadius.chip,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 14,
              color: accentColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AppTypography.caption.copyWith(
                  color: c.textSecondary,
                ),
                children: [
                  const TextSpan(text: 'Tek periyodik kayıt oluşturulacak. '),
                  TextSpan(
                    text: monthDetail.monthName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' net: '),
                  TextSpan(
                    text: CurrencyFormatter.formatNoDecimal(
                        monthDetail.netTakeHome),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const TextSpan(text: '\nHer ay net tutar otomatik hesaplanır'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
