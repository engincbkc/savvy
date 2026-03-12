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
    @Default(false) bool isDeleted,
    required DateTime createdAt,
  }) = _Income;

  factory Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);
}
