import 'package:csv/csv.dart';

/// Savvy CSV import format:
/// Tarih,Tür,Tutar,Kategori,Not
/// 2025-01-15,Gelir,5000,Maaş,Ocak maaşı
/// 2025-01-20,Gider,250,Market,
/// 2025-01-25,Birikim,1000,Acil Durum Fonu,
///
/// Tür values: "Gelir" | "Gider" | "Birikim"
class CsvImportService {
  static const List<String> requiredHeaders = [
    'Tarih',
    'Tür',
    'Tutar',
    'Kategori',
  ];

  static const String templateCsv =
      'Tarih,Tür,Tutar,Kategori,Not\n'
      '2026-01-15,Gelir,5000,Maaş,Ocak maaşı\n'
      '2026-01-20,Gider,250,Market,Haftalık alışveriş\n'
      '2026-01-25,Birikim,1000,Acil Durum Fonu,\n';

  /// Parse CSV string into a list of [ImportRow] objects.
  /// Throws [CsvParseException] if headers are missing or invalid.
  static List<ImportRow> parse(String csvContent) {
    final rows = const CsvDecoder().convert(csvContent);

    if (rows.isEmpty) {
      throw CsvParseException('CSV dosyası boş.');
    }

    // Validate headers
    final headers = rows.first.map((h) => h.toString().trim()).toList();
    for (final required in requiredHeaders) {
      if (!headers.contains(required)) {
        throw CsvParseException('Gerekli sütun eksik: "$required"');
      }
    }

    final tarihIdx = headers.indexOf('Tarih');
    final turIdx = headers.indexOf('Tür');
    final tutarIdx = headers.indexOf('Tutar');
    final kategoriIdx = headers.indexOf('Kategori');
    final notIdx = headers.indexOf('Not');

    final result = <ImportRow>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      // Skip completely empty rows
      if (row.every((cell) => cell.toString().trim().isEmpty)) continue;

      final dateStr = _cell(row, tarihIdx);
      final type = _cell(row, turIdx);
      final amountStr = _cell(row, tutarIdx);
      final category = _cell(row, kategoriIdx);
      final note = notIdx >= 0 ? _cell(row, notIdx) : null;

      // Parse date (supports YYYY-MM-DD and DD.MM.YYYY)
      DateTime? date;
      final trimmedDate = dateStr.trim();
      try {
        if (trimmedDate.contains('.')) {
          // DD.MM.YYYY format (Turkish)
          final parts = trimmedDate.split('.');
          if (parts.length == 3) {
            date = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          } else {
            throw const FormatException();
          }
        } else {
          date = DateTime.parse(trimmedDate);
        }
      } catch (_) {
        result.add(ImportRow.invalid(
          rawLine: i + 1,
          error:
              'Geçersiz tarih formatı: "$dateStr" (YYYY-AA-GG veya GG.AA.YYYY bekleniyor)',
        ));
        continue;
      }

      // Parse amount
      final normalizedAmount = amountStr
          .trim()
          .replaceAll('₺', '')
          .replaceAll(' ', '')
          .replaceAll('.', '') // TR thousands
          .replaceAll(',', '.'); // TR decimal
      final amount = double.tryParse(normalizedAmount);
      if (amount == null || amount <= 0) {
        result.add(ImportRow.invalid(
          rawLine: i + 1,
          error: 'Geçersiz tutar: "$amountStr"',
        ));
        continue;
      }

      // Validate type
      const validTypes = ['Gelir', 'Gider', 'Birikim'];
      if (!validTypes.contains(type.trim())) {
        result.add(ImportRow.invalid(
          rawLine: i + 1,
          error: 'Geçersiz tür: "$type" (Gelir, Gider veya Birikim olmalı)',
        ));
        continue;
      }

      if (category.trim().isEmpty) {
        result.add(ImportRow.invalid(
          rawLine: i + 1,
          error: 'Kategori boş bırakılamaz',
        ));
        continue;
      }

      result.add(ImportRow(
        rawLine: i + 1,
        date: date,
        type: type.trim(),
        amount: amount,
        category: category.trim(),
        note: (note != null && note.trim().isNotEmpty) ? note.trim() : null,
        isValid: true,
        error: null,
      ));
    }

    return result;
  }

  static String _cell(List<dynamic> row, int idx) {
    if (idx < 0 || idx >= row.length) return '';
    return row[idx].toString();
  }
}

class ImportRow {
  final int rawLine;
  final DateTime? date;
  final String type;
  final double? amount;
  final String category;
  final String? note;
  final bool isValid;
  final String? error;

  const ImportRow({
    required this.rawLine,
    required this.date,
    required this.type,
    required this.amount,
    required this.category,
    this.note,
    required this.isValid,
    required this.error,
  });

  factory ImportRow.invalid({required int rawLine, required String error}) {
    return ImportRow(
      rawLine: rawLine,
      date: null,
      type: '',
      amount: null,
      category: '',
      note: null,
      isValid: false,
      error: error,
    );
  }
}

class CsvParseException implements Exception {
  final String message;
  const CsvParseException(this.message);

  @override
  String toString() => 'CsvParseException: $message';
}
