import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

@freezed
abstract class SavingsGoal with _$SavingsGoal {
  const factory SavingsGoal({
    required String id,
    required String title,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    DateTime? targetDate,
    required SavingsCategory category,
    @Default('#D97706') String colorHex,
    @Default('target') String iconName,
    @Default(GoalStatus.active) GoalStatus status,
    required DateTime createdAt,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);
}
