// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Savings _$SavingsFromJson(Map<String, dynamic> json) => _Savings(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: $enumDecode(_$SavingsCategoryEnumMap, json['category']),
  goalId: json['goalId'] as String?,
  note: json['note'] as String?,
  date: DateTime.parse(json['date'] as String),
  status:
      $enumDecodeNullable(_$SavingsStatusEnumMap, json['status']) ??
      SavingsStatus.active,
  isDeleted: json['isDeleted'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SavingsToJson(_Savings instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'category': _$SavingsCategoryEnumMap[instance.category]!,
  'goalId': instance.goalId,
  'note': instance.note,
  'date': instance.date.toIso8601String(),
  'status': _$SavingsStatusEnumMap[instance.status]!,
  'isDeleted': instance.isDeleted,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$SavingsCategoryEnumMap = {
  SavingsCategory.emergency: 'emergency',
  SavingsCategory.goal: 'goal',
  SavingsCategory.gold: 'gold',
  SavingsCategory.forex: 'forex',
  SavingsCategory.stock: 'stock',
  SavingsCategory.fund: 'fund',
  SavingsCategory.deposit: 'deposit',
  SavingsCategory.retirement: 'retirement',
  SavingsCategory.other: 'other',
};

const _$SavingsStatusEnumMap = {
  SavingsStatus.active: 'active',
  SavingsStatus.withdrawn: 'withdrawn',
  SavingsStatus.completed: 'completed',
};
