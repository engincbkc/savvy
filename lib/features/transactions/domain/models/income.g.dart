// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Income _$IncomeFromJson(Map<String, dynamic> json) => _Income(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: $enumDecode(_$IncomeCategoryEnumMap, json['category']),
  person: json['person'] as String?,
  source: json['source'] as String?,
  date: DateTime.parse(json['date'] as String),
  note: json['note'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringEndDate: json['recurringEndDate'] == null
      ? null
      : DateTime.parse(json['recurringEndDate'] as String),
  isGross: json['isGross'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  monthlyOverrides:
      (json['monthlyOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  isSettled: json['isSettled'] as bool? ?? false,
  settledMonths:
      (json['settledMonths'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
);

Map<String, dynamic> _$IncomeToJson(_Income instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'category': _$IncomeCategoryEnumMap[instance.category]!,
  'person': instance.person,
  'source': instance.source,
  'date': instance.date.toIso8601String(),
  'note': instance.note,
  'isRecurring': instance.isRecurring,
  'recurringEndDate': instance.recurringEndDate?.toIso8601String(),
  'isGross': instance.isGross,
  'isDeleted': instance.isDeleted,
  'createdAt': instance.createdAt.toIso8601String(),
  'monthlyOverrides': instance.monthlyOverrides,
  'isSettled': instance.isSettled,
  'settledMonths': instance.settledMonths,
};

const _$IncomeCategoryEnumMap = {
  IncomeCategory.salary: 'salary',
  IncomeCategory.sideJob: 'sideJob',
  IncomeCategory.freelance: 'freelance',
  IncomeCategory.transfer: 'transfer',
  IncomeCategory.debtCollection: 'debtCollection',
  IncomeCategory.refund: 'refund',
  IncomeCategory.rentalIncome: 'rentalIncome',
  IncomeCategory.investment: 'investment',
  IncomeCategory.other: 'other',
};
