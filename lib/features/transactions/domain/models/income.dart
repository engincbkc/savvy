import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';

part 'income.freezed.dart';
part 'income.g.dart';

@freezed
abstract class Income with _$Income {
  const factory Income({
    required String id,
    required double amount,
    required IncomeCategory category,
    String? person,
    String? source,
    required DateTime date,
    String? note,
    @Default(false) bool isRecurring,
    DateTime? recurringEndDate,
    /// true ise [amount] brüt tutardır; net, ay bazında hesaplanır.
    @Default(false) bool isGross,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
    /// Per-month amount overrides for recurring items.
    /// Key: "YYYY-MM", Value: override amount for that month.
    /// Months not present use the default [amount].
    @Default({}) Map<String, double> monthlyOverrides,
    /// true = alındı (gelir tahsil edildi), false = beklemede.
    /// Tek seferlik işlemler için kullanılır.
    @Default(false) bool isSettled,
    /// Recurring işlemlerin ay bazlı settled durumu.
    /// Key: "YYYY-MM", Value: true = alındı.
    /// Map'te olmayan aylar isSettled default'unu kullanır.
    @Default({}) Map<String, bool> settledMonths,
  }) = _Income;

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);
}
