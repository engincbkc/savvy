import 'package:flutter/services.dart';

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
/// Preserves cursor position correctly: counts digits to the left of cursor
/// before formatting, then restores the same digit-count position after.
class ThousandFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-digit, non-comma chars
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d,]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // Count how many "significant" chars (digits + comma) are to the LEFT
    // of the cursor in the raw input — separators (dots) don't count.
    final cursorPos = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    int digitsBeforeCursor = 0;
    for (int i = 0; i < cursorPos && i < newValue.text.length; i++) {
      final ch = newValue.text[i];
      if (ch != '.') digitsBeforeCursor++;
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

    // Restore cursor: walk through formatted string, counting significant
    // chars (non-dot) until we reach the same count as before.
    int newCursorPos = 0;
    int counted = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (counted >= digitsBeforeCursor) break;
      newCursorPos = i + 1;
      if (formatted[i] != '.') counted++;
    }
    newCursorPos = newCursorPos.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }
}
