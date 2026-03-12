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
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
