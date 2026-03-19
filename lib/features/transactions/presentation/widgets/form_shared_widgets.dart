import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/savvy_colors.dart';
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
                ThousandFormatter(),
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
  final cleaned = v.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', '');
  final parsed = double.tryParse(cleaned);
  if (parsed == null || parsed <= 0) return 'Geçerli bir tutar giriniz';
  if (parsed > 10000000) return 'Maksimum tutar ₺10.000.000';
  return null;
}

/// Parses a Turkish-format amount string to double.
double parseAmount(String text) =>
    double.parse(text.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', ''));

/// Returns true if the amount text represents a valid positive number.
bool isAmountValid(String text) {
  if (text.trim().isEmpty) return false;
  final cleaned = text.replaceAll('.', '').replaceAll(',', '.').replaceAll(' ', '');
  final parsed = double.tryParse(cleaned);
  return parsed != null && parsed > 0;
}

/// TextInputFormatter that adds thousand separators (Turkish dot style: 60000 → 60.000).
class ThousandFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digit, non-comma chars
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d,]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '', selection: const TextSelection.collapsed(offset: 0));
    }

    // Split by comma (decimal separator in TR)
    final parts = digitsOnly.split(',');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? ',${parts[1]}' : '';

    // Add dots as thousand separator
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }
    final formatted = '$buffer$decPart';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
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
      child: SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
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

/// Duration picker with 3 modes: Aylık, Yıllık, Tam Tarih.
void showMonthDurationPicker({
  required BuildContext context,
  required DateTime startDate,
  required DateTime? currentEndDate,
  required ValueChanged<DateTime> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => _DurationPickerSheet(
      startDate: startDate,
      currentEndDate: currentEndDate,
      onSelected: (date) {
        Navigator.pop(ctx);
        onSelected(date);
      },
    ),
  );
}

class _DurationPickerSheet extends StatefulWidget {
  final DateTime startDate;
  final DateTime? currentEndDate;
  final ValueChanged<DateTime> onSelected;

  const _DurationPickerSheet({
    required this.startDate,
    required this.currentEndDate,
    required this.onSelected,
  });

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  int _mode = 0; // 0=aylık, 1=yıllık, 2=tam tarih
  final _customController = TextEditingController();

  static const _monthPresets = [3, 6, 12, 18, 24];
  static const _yearPresets = [2, 3, 5, 10, 15];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Süre Seç',
            style: AppTypography.headlineSmall.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Periyodik işlem ne kadar sürecek?',
            style: AppTypography.caption.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: AppSpacing.base),

          // Mode tabs
          Padding(
            padding: AppSpacing.screenH,
            child: Row(
              children: [
                _ModeTab(label: 'Aylık', isActive: _mode == 0, onTap: () => setState(() => _mode = 0)),
                const SizedBox(width: AppSpacing.sm),
                _ModeTab(label: 'Yıllık', isActive: _mode == 1, onTap: () => setState(() => _mode = 1)),
                const SizedBox(width: AppSpacing.sm),
                _ModeTab(label: 'Tam Tarih', isActive: _mode == 2, onTap: () => setState(() => _mode = 2)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),

          // Content
          if (_mode == 0) ...[
            _buildGrid(c, _monthPresets, (n) => '$n ay', (n) => DateTime(
              widget.startDate.year, widget.startDate.month + n, widget.startDate.day,
            )),
            const SizedBox(height: AppSpacing.base),
            _buildCustomInput(c, 'ay', (n) => DateTime(
              widget.startDate.year, widget.startDate.month + n, widget.startDate.day,
            )),
          ],
          if (_mode == 1) ...[
            _buildGrid(c, _yearPresets, (n) => '$n yıl', (n) => DateTime(
              widget.startDate.year + n, widget.startDate.month, widget.startDate.day,
            )),
            const SizedBox(height: AppSpacing.base),
            _buildCustomInput(c, 'yıl', (n) => DateTime(
              widget.startDate.year + n, widget.startDate.month, widget.startDate.day,
            )),
          ],
          if (_mode == 2) _buildDateButton(c),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildGrid(SavvyColors c, List<int> presets, String Function(int) labelOf, DateTime Function(int) dateOf) {
    return Padding(
      padding: AppSpacing.screenH,
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: presets.map((n) {
          final endDate = dateOf(n);
          final isSelected = widget.currentEndDate != null &&
              widget.currentEndDate!.year == endDate.year &&
              widget.currentEndDate!.month == endDate.month;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onSelected(endDate);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? c.brandPrimary : c.surfaceOverlay,
                borderRadius: AppRadius.chip,
                border: Border.all(color: isSelected ? c.brandPrimary : c.borderDefault),
              ),
              child: Text(
                labelOf(n),
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : c.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomInput(SavvyColors c, String unit, DateTime Function(int) dateOf) {
    return Padding(
      padding: AppSpacing.screenH,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Örn: 48',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              ),
              onSubmitted: (val) {
                final n = int.tryParse(val);
                if (n != null && n > 0) {
                  widget.onSelected(dateOf(n));
                }
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(unit, style: AppTypography.labelMedium.copyWith(color: c.textSecondary)),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              final n = int.tryParse(_customController.text);
              if (n != null && n > 0) {
                HapticFeedback.selectionClick();
                widget.onSelected(dateOf(n));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: c.brandPrimary,
                borderRadius: AppRadius.chip,
              ),
              child: Text('Uygula', style: AppTypography.labelSmall.copyWith(
                color: Colors.white, fontWeight: FontWeight.w600,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(SavvyColors c) {
    return Padding(
      padding: AppSpacing.screenH,
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: widget.currentEndDate ?? widget.startDate.add(const Duration(days: 365)),
            firstDate: widget.startDate,
            lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
          );
          if (picked != null) widget.onSelected(picked);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: c.surfaceOverlay,
            borderRadius: AppRadius.input,
            border: Border.all(color: c.borderDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: c.brandPrimary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.currentEndDate != null
                    ? formatDateTR(widget.currentEndDate!)
                    : 'Takvimden tarih seç',
                style: AppTypography.labelMedium.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? c.brandPrimary : c.surfaceOverlay,
            borderRadius: AppRadius.chip,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isActive ? Colors.white : c.textSecondary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
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
