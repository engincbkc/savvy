import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';

part 'savings.freezed.dart';
part 'savings.g.dart';

@freezed
abstract class Savings with _$Savings {
  const factory Savings({
    required String id,
    required double amount,
    @Default(SavingsCategory.other) SavingsCategory category,
    String? title,
    String? goalId,
    String? note,
    required DateTime date,
    @Default(SavingsStatus.active) SavingsStatus status,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
  }) = _Savings;

  factory Savings.fromJson(Map<String, dynamic> json) =>
      _$SavingsFromJson(json);
}
