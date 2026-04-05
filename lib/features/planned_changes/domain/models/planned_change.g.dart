// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlannedChange _$PlannedChangeFromJson(Map<String, dynamic> json) =>
    _PlannedChange(
      id: json['id'] as String,
      parentId: json['parentId'] as String,
      parentType: json['parentType'] as String,
      newAmount: (json['newAmount'] as num).toDouble(),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      isGross: json['isGross'] as bool? ?? false,
      note: json['note'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PlannedChangeToJson(_PlannedChange instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'parentType': instance.parentType,
      'newAmount': instance.newAmount,
      'effectiveDate': instance.effectiveDate.toIso8601String(),
      'isGross': instance.isGross,
      'note': instance.note,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
    };
