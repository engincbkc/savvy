/// Helper extension for yearMonth string operations.
extension DateTimeYearMonth on DateTime {
  /// Returns "2025-03" format
  String toYearMonth() =>
      '${year.toString()}-${month.toString().padLeft(2, '0')}';
}

class YearMonthRange {
  final DateTime start;
  final DateTime end;

  const YearMonthRange({required this.start, required this.end});

  factory YearMonthRange.from(String yearMonth) {
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final start = DateTime.utc(year, month, 1);
    final end = DateTime.utc(year, month + 1, 1);
    return YearMonthRange(start: start, end: end);
  }
}

/// Centralized Turkish month names and label helpers.
class MonthLabels {
  MonthLabels._();

  static const _months = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// "Ocak 2025"
  static String full(String yearMonth) {
    final parts = yearMonth.split('-');
    final year = parts[0];
    final month = int.parse(parts[1]);
    return '${_months[month]} $year';
  }

  /// "Oca '25"
  static String short(String yearMonth) {
    final parts = yearMonth.split('-');
    final month = int.parse(parts[1]);
    final name = _months[month];
    final abbr = name.length > 3 ? name.substring(0, 3) : name;
    return '$abbr \'${parts[0].substring(2)}';
  }

  /// "Oca" (sadece kısa ay ismi)
  static String shortName(String yearMonth) {
    final parts = yearMonth.split('-');
    final month = int.parse(parts[1]);
    return _months[month].substring(0, 3);
  }

  /// "Ocak" (tam ay ismi)
  static String monthName(int month) => _months[month];
}
