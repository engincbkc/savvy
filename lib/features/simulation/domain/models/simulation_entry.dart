import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';
import 'package:savvy/features/simulation/domain/models/simulation_change.dart';

part 'simulation_entry.freezed.dart';
part 'simulation_entry.g.dart';

@freezed
abstract class SimulationEntry with _$SimulationEntry {
  const SimulationEntry._();

  const factory SimulationEntry({
    required String id,
    required String title,
    String? description,
    SimulationTemplate? template,
    @Default('sparkles') String iconName,
    @Default('#3F83F8') String colorHex,
    @Default([]) List<SimulationChange> changes,
    String? compareWithId,
    // Legacy fields — kept for backward compat with old Firestore data
    // ignore: deprecated_member_use_from_same_package
    SimulationType? type,
    @Default({}) Map<String, dynamic> parameters,
    @Default(false) bool isIncluded,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SimulationEntry;

  factory SimulationEntry.fromJson(Map<String, dynamic> json) =>
      _$SimulationEntryFromJson(json);
}
