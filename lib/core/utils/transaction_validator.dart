import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_validator.freezed.dart';

class TransactionValidator {
  static const double _maxAmount = 10000000.0;
  static const int _maxNoteLength = 200;

  static ValidationResult<double> validateAmount(String? input) {
    if (input == null || input.trim().isEmpty) {
      return const ValidationResult.error('Tutar giriniz');
    }
    final normalized = input.replaceAll(',', '.').replaceAll(' ', '');
    final amount = double.tryParse(normalized);
    if (amount == null) {
      return const ValidationResult.error('Geçerli bir tutar giriniz');
    }
    if (amount <= 0) {
      return const ValidationResult.error("Tutar 0'dan büyük olmalıdır");
    }
    if (amount > _maxAmount) {
      return const ValidationResult.error('Maksimum tutar ₺10.000.000');
    }
    return ValidationResult.ok(amount);
  }

  static ValidationResult<DateTime> validateDate(DateTime? date) {
    if (date == null) return const ValidationResult.error('Tarih seçiniz');
    final now = DateTime.now();
    final minDate = DateTime(2020, 1, 1);
    if (date.isBefore(minDate)) {
      return const ValidationResult.error('2020 öncesi tarih girilemez');
    }
    if (date.isAfter(now.add(const Duration(days: 366)))) {
      return const ValidationResult.error('1 yıldan fazla ilerisi seçilemez');
    }
    return ValidationResult.ok(date);
  }

  static ValidationResult<String?> validateNote(String? note) {
    if (note == null || note.isEmpty) return const ValidationResult.ok(null);
    if (note.length > _maxNoteLength) {
      return ValidationResult.error('Not en fazla $_maxNoteLength karakter');
    }
    return ValidationResult.ok(note);
  }
}

@freezed
abstract class ValidationResult<T> with _$ValidationResult<T> {
  const factory ValidationResult.ok([T? value]) = ValidationOk;
  const factory ValidationResult.error(String message) = ValidationError;
}
