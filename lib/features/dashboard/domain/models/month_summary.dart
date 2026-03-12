import 'package:freezed_annotation/freezed_annotation.dart';

part 'month_summary.freezed.dart';
part 'month_summary.g.dart';

@freezed
abstract class MonthSummary with _$MonthSummary {
  const factory MonthSummary({
    required String yearMonth, // "2025-03"
    @Default(0.0) double totalIncome,
    @Default(0.0) double totalExpense,
    @Default(0.0) double totalSavings,
    @Default(0.0) double netBalance,
    @Default(0.0) double carryOver,
    @Default(0.0) double netWithCarryOver,
    @Default(0.0) double savingsRate,
    @Default(0.0) double expenseRate,
    @Default(0) int healthScore,
    required DateTime updatedAt,
  }) = _MonthSummary;

  factory MonthSummary.fromJson(Map<String, dynamic> json) =>
      _$MonthSummaryFromJson(json);
}
