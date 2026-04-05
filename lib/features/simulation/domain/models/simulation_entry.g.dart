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
      template: $enumDecodeNullable(
        _$SimulationTemplateEnumMap,
        json['template'],
      ),
      iconName: json['iconName'] as String? ?? 'sparkles',
      colorHex: json['colorHex'] as String? ?? '#3F83F8',
      changes:
          (json['changes'] as List<dynamic>?)
              ?.map((e) => SimulationChange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      compareWithId: json['compareWithId'] as String?,
      type: $enumDecodeNullable(_$SimulationTypeEnumMap, json['type']),
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
      'template': _$SimulationTemplateEnumMap[instance.template],
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'changes': instance.changes,
      'compareWithId': instance.compareWithId,
      'type': _$SimulationTypeEnumMap[instance.type],
      'parameters': instance.parameters,
      'isIncluded': instance.isIncluded,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$SimulationTemplateEnumMap = {
  SimulationTemplate.credit: 'credit',
  SimulationTemplate.housing: 'housing',
  SimulationTemplate.car: 'car',
  SimulationTemplate.rentChange: 'rentChange',
  SimulationTemplate.salaryChange: 'salaryChange',
  SimulationTemplate.investment: 'investment',
  SimulationTemplate.custom: 'custom',
};

const _$SimulationTypeEnumMap = {
  SimulationType.car: 'car',
  SimulationType.housing: 'housing',
  SimulationType.credit: 'credit',
  SimulationType.vacation: 'vacation',
  SimulationType.tech: 'tech',
  SimulationType.custom: 'custom',
};
