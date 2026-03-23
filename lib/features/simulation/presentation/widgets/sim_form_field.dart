import 'package:flutter/material.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';

class SimFormField extends StatelessWidget {
  final String label;
  final String suffix;
  final TextEditingController controller;
  final IconData icon;
  final Color color;
  final bool decimal;
  final String? hint;

  const SimFormField({
    super.key,
    required this.label,
    required this.suffix,
    required this.controller,
    required this.icon,
    required this.color,
    this.decimal = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      style: AppTypography.bodyLarge.copyWith(color: c.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.labelMedium.copyWith(color: c.textSecondary),
        hintText: hint,
        hintStyle: AppTypography.bodySmall.copyWith(color: c.textTertiary),
        suffixText: suffix,
        suffixStyle: AppTypography.labelMedium.copyWith(color: c.textTertiary),
        prefixIcon: Icon(icon, size: 18, color: color),
        filled: true,
        fillColor: c.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: c.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
