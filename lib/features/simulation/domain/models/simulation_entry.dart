import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:savvy/core/constants/financial_enums.dart';

part 'simulation_entry.freezed.dart';
part 'simulation_entry.g.dart';

@freezed
abstract class SimulationEntry with _$SimulationEntry {
  const factory SimulationEntry({
    required String id,
    required String title,
    String? description,
    required SimulationType type,
    @Default('sparkles') String iconName,
    @Default('#3F83F8') String colorHex,
    @Default({}) Map<String, dynamic> parameters,
    @Default(false) bool isIncluded,
    @Default(false) bool isDeleted,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SimulationEntry;

  factory SimulationEntry.fromJson(Map<String, dynamic> json) =>
      _$SimulationEntryFromJson(json);
}
