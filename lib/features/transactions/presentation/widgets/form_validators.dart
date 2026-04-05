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
