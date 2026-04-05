import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';

part 'budget_limit.freezed.dart';
part 'budget_limit.g.dart';

@freezed
abstract class BudgetLimit with _$BudgetLimit {
  const factory BudgetLimit({
    required String id,
    required ExpenseCategory category,
    required double monthlyLimit,
    @Default(true) bool isActive,
    required DateTime createdAt,
    @Default(false) bool isDeleted,
  }) = _BudgetLimit;

  factory BudgetLimit.fromJson(Map<String, dynamic> json) =>
      _$BudgetLimitFromJson(json);
}
