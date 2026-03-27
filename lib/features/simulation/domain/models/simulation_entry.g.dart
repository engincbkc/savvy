// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SimulationEntry _$SimulationEntryFromJson(Map<String, dynamic> json) =>
    _SimulationEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: $enumDecode(_$SimulationTypeEnumMap, json['type']),
      iconName: json['iconName'] as String? ?? 'sparkles',
      colorHex: json['colorHex'] as String? ?? '#3F83F8',
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
      isIncluded: json['isIncluded'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SimulationEntryToJson(_SimulationEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$SimulationTypeEnumMap[instance.type]!,
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'parameters': instance.parameters,
      'isIncluded': instance.isIncluded,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SimulationTypeEnumMap = {
  SimulationType.car: 'car',
  SimulationType.housing: 'housing',
  SimulationType.credit: 'credit',
  SimulationType.vacation: 'vacation',
  SimulationType.tech: 'tech',
  SimulationType.custom: 'custom',
};
