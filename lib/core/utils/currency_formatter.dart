import 'package:intl/intl.dart';

/// Currency formatting — UI never shows raw doubles. BL-005.
class CurrencyFormatter {
  static final _standard = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final _compact = NumberFormat.compactCurrency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 1,
  );

  static final _noDecimal = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  /// Standard: ₺1.250,00
  static String format(double amount) => _standard.format(amount);

  /// No decimal: ₺1.250
  static String formatNoDecimal(double amount) => _noDecimal.format(amount);

  /// Compact: ₺1,2B for 1M+, standard otherwise
  static String compact(double amount) =>
      amount.abs() >= 1000000 ? _compact.format(amount) : format(amount);

  /// Signed: +₺1.250,00 or -₺500,00
  static String withSign(double amount) {
    final abs = format(amount.abs());
    return amount >= 0 ? '+$abs' : '-$abs';
  }

  /// Change percent: +%5,2 or -%3,1
  static String changePercent(double ratio) {
    final pct = (ratio * 100).abs();
    final sign = ratio >= 0 ? '+' : '-';
    return '$sign%${pct.toStringAsFixed(1)}';
  }

  /// Percent: %38,5
  static String percent(double ratio) =>
      '%${(ratio * 100).toStringAsFixed(1)}';

  /// Parse Turkish currency input to double
  static double? parse(String input) {
    final cleaned = input
        .replaceAll('₺', '')
        .replaceAll(' ', '')
        .replaceAll('.', '') // TR thousands separator
        .replaceAll(',', '.'); // TR decimal → dot
    return double.tryParse(cleaned);
  }
}
