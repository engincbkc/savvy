// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingsGoal _$SavingsGoalFromJson(Map<String, dynamic> json) => _SavingsGoal(
  id: json['id'] as String,
  title: json['title'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
  targetDate: json['targetDate'] == null
      ? null
      : DateTime.parse(json['targetDate'] as String),
  category: $enumDecode(_$SavingsCategoryEnumMap, json['category']),
  colorHex: json['colorHex'] as String? ?? '#D97706',
  iconName: json['iconName'] as String? ?? 'target',
  status:
      $enumDecodeNullable(_$GoalStatusEnumMap, json['status']) ??
      GoalStatus.active,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SavingsGoalToJson(_SavingsGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'targetDate': instance.targetDate?.toIso8601String(),
      'category': _$SavingsCategoryEnumMap[instance.category]!,
      'colorHex': instance.colorHex,
      'iconName': instance.iconName,
      'status': _$GoalStatusEnumMap[instance.status]!,
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

const _$GoalStatusEnumMap = {
  GoalStatus.active: 'active',
  GoalStatus.completed: 'completed',
  GoalStatus.cancelled: 'cancelled',
};
