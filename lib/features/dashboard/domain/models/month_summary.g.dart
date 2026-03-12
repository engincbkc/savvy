// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthSummary _$MonthSummaryFromJson(Map<String, dynamic> json) =>
    _MonthSummary(
      yearMonth: json['yearMonth'] as String,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0.0,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0.0,
      netBalance: (json['netBalance'] as num?)?.toDouble() ?? 0.0,
      carryOver: (json['carryOver'] as num?)?.toDouble() ?? 0.0,
      netWithCarryOver: (json['netWithCarryOver'] as num?)?.toDouble() ?? 0.0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      expenseRate: (json['expenseRate'] as num?)?.toDouble() ?? 0.0,
      healthScore: (json['healthScore'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MonthSummaryToJson(_MonthSummary instance) =>
    <String, dynamic>{
      'yearMonth': instance.yearMonth,
      'totalIncome': instance.totalIncome,
      'totalExpense': instance.totalExpense,
      'totalSavings': instance.totalSavings,
      'netBalance': instance.netBalance,
      'carryOver': instance.carryOver,
      'netWithCarryOver': instance.netWithCarryOver,
      'savingsRate': instance.savingsRate,
      'expenseRate': instance.expenseRate,
      'healthScore': instance.healthScore,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
