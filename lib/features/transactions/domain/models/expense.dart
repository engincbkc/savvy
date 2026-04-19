import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required String id,
    required double amount,
    required ExpenseCategory category,
    @Default(ExpenseType.variable) ExpenseType expenseType,
    String? subcategory,
    String? person,
    required DateTime date,
    String? note,
    @Default(false) bool isRecurring,
    DateTime? recurringEndDate,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
    /// Per-month amount overrides for recurring items.
    /// Key: "YYYY-MM", Value: override amount for that month.
    /// Months not present use the default [amount].
    @Default({}) Map<String, double> monthlyOverrides,
    /// true = ödendi (gider ödendi), false = beklemede
    @Default(false) bool isSettled,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
