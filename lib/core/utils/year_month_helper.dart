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
