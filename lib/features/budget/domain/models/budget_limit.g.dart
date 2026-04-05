// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_limit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetLimit _$BudgetLimitFromJson(Map<String, dynamic> json) => _BudgetLimit(
  id: json['id'] as String,
  category: $enumDecode(_$ExpenseCategoryEnumMap, json['category']),
  monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$BudgetLimitToJson(_BudgetLimit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': _$ExpenseCategoryEnumMap[instance.category]!,
      'monthlyLimit': instance.monthlyLimit,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'isDeleted': instance.isDeleted,
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
