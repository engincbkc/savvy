import 'package:freezed_annotation/freezed_annotation.dart';

part 'planned_change.freezed.dart';
part 'planned_change.g.dart';

@freezed
abstract class PlannedChange with _$PlannedChange {
  const factory PlannedChange({
    required String id,
    required String parentId, // Income.id or Expense.id
    required String parentType, // 'income' or 'expense'
    required double newAmount, // new amount from effectiveDate
    required DateTime effectiveDate,
    @Default(false) bool isGross, // for income: is newAmount gross?
    String? note,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
  }) = _PlannedChange;

  factory PlannedChange.fromJson(Map<String, dynamic> json) =>
      _$PlannedChangeFromJson(json);
}
