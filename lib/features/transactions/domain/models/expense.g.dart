// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
  expenseType:
      $enumDecodeNullable(_$ExpenseTypeEnumMap, json['expenseType']) ??
      ExpenseType.variable,
  subcategory: json['subcategory'] as String?,
  person: json['person'] as String?,
  date: DateTime.parse(json['date'] as String),
  note: json['note'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringEndDate: json['recurringEndDate'] == null
      ? null
      : DateTime.parse(json['recurringEndDate'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'category': _$ExpenseCategoryEnumMap[instance.category]!,
  'expenseType': _$ExpenseTypeEnumMap[instance.expenseType]!,
  'subcategory': instance.subcategory,
  'person': instance.person,
  'date': instance.date.toIso8601String(),
  'note': instance.note,
  'isRecurring': instance.isRecurring,
  'recurringEndDate': instance.recurringEndDate?.toIso8601String(),
  'isDeleted': instance.isDeleted,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$ExpenseCategoryEnumMap = {
  ExpenseCategory.rent: 'rent',
  ExpenseCategory.market: 'market',
  ExpenseCategory.transport: 'transport',
  ExpenseCategory.bills: 'bills',
  ExpenseCategory.creditCard: 'creditCard',
  ExpenseCategory.loanInstallment: 'loanInstallment',
  ExpenseCategory.health: 'health',
  ExpenseCategory.education: 'education',
  ExpenseCategory.food: 'food',
  ExpenseCategory.entertainment: 'entertainment',
  ExpenseCategory.clothing: 'clothing',
  ExpenseCategory.subscription: 'subscription',
  ExpenseCategory.advertising: 'advertising',
  ExpenseCategory.businessTool: 'businessTool',
  ExpenseCategory.tax: 'tax',
  ExpenseCategory.other: 'other',
};

const _$ExpenseTypeEnumMap = {
  ExpenseType.fixed: 'fixed',
  ExpenseType.variable: 'variable',
  ExpenseType.discretionary: 'discretionary',
  ExpenseType.business: 'business',
};
