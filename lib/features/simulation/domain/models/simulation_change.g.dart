// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_change.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditChange _$CreditChangeFromJson(Map<String, dynamic> json) => CreditChange(
  principal: (json['principal'] as num).toDouble(),
  monthlyRate: (json['monthlyRate'] as num).toDouble(),
  termMonths: (json['termMonths'] as num).toInt(),
  label: json['label'] as String? ?? 'Kredi',
  $type: json['changeType'] as String?,
);

Map<String, dynamic> _$CreditChangeToJson(CreditChange instance) =>
    <String, dynamic>{
      'principal': instance.principal,
      'monthlyRate': instance.monthlyRate,
      'termMonths': instance.termMonths,
      'label': instance.label,
      'changeType': instance.$type,
    };

HousingChange _$HousingChangeFromJson(Map<String, dynamic> json) =>
    HousingChange(
      price: (json['price'] as num).toDouble(),
      downPayment: (json['downPayment'] as num?)?.toDouble() ?? 0,
      monthlyRate: (json['monthlyRate'] as num).toDouble(),
      termMonths: (json['termMonths'] as num).toInt(),
      monthlyExtras: (json['monthlyExtras'] as num?)?.toDouble() ?? 0,
      label: json['label'] as String? ?? 'Ev Alımı',
      $type: json['changeType'] as String?,
    );

Map<String, dynamic> _$HousingChangeToJson(HousingChange instance) =>
    <String, dynamic>{
      'price': instance.price,
      'downPayment': instance.downPayment,
      'monthlyRate': instance.monthlyRate,
      'termMonths': instance.termMonths,
      'monthlyExtras': instance.monthlyExtras,
      'label': instance.label,
      'changeType': instance.$type,
    };

CarChange _$CarChangeFromJson(Map<String, dynamic> json) => CarChange(
  price: (json['price'] as num).toDouble(),
  downPayment: (json['downPayment'] as num?)?.toDouble() ?? 0,
  monthlyRate: (json['monthlyRate'] as num).toDouble(),
  termMonths: (json['termMonths'] as num).toInt(),
  monthlyRunningCosts: (json['monthlyRunningCosts'] as num?)?.toDouble() ?? 0,
  label: json['label'] as String? ?? 'Araç Alımı',
  $type: json['changeType'] as String?,
);

Map<String, dynamic> _$CarChangeToJson(CarChange instance) => <String, dynamic>{
  'price': instance.price,
  'downPayment': instance.downPayment,
  'monthlyRate': instance.monthlyRate,
  'termMonths': instance.termMonths,
  'monthlyRunningCosts': instance.monthlyRunningCosts,
  'label': instance.label,
  'changeType': instance.$type,
};

RentChangeChange _$RentChangeChangeFromJson(Map<String, dynamic> json) =>
    RentChangeChange(
      currentRent: (json['currentRent'] as num).toDouble(),
      newRent: (json['newRent'] as num).toDouble(),
      annualIncreaseRate:
          (json['annualIncreaseRate'] as num?)?.toDouble() ?? 0.0,
      label: json['label'] as String? ?? 'Kira Değişimi',
      $type: json['changeType'] as String?,
    );

Map<String, dynamic> _$RentChangeChangeToJson(RentChangeChange instance) =>
    <String, dynamic>{
      'currentRent': instance.currentRent,
      'newRent': instance.newRent,
      'annualIncreaseRate': instance.annualIncreaseRate,
      'label': instance.label,
      'changeType': instance.$type,
    };

SalaryChangeChange _$SalaryChangeChangeFromJson(Map<String, dynamic> json) =>
    SalaryChangeChange(
      currentGross: (json['currentGross'] as num).toDouble(),
      newGross: (json['newGross'] as num).toDouble(),
      label: json['label'] as String? ?? 'Maaş Değişikliği',
      $type: json['changeType'] as String?,
    );

Map<String, dynamic> _$SalaryChangeChangeToJson(SalaryChangeChange instance) =>
    <String, dynamic>{
      'currentGross': instance.currentGross,
      'newGross': instance.newGross,
      'label': instance.label,
      'changeType': instance.$type,
    };

IncomeChange _$IncomeChangeFromJson(Map<String, dynamic> json) => IncomeChange(
  amount: (json['amount'] as num).toDouble(),
  description: json['description'] as String? ?? '',
  isRecurring: json['isRecurring'] as bool? ?? true,
  label: json['label'] as String? ?? 'Gelir',
  $type: json['changeType'] as String?,
);

Map<String, dynamic> _$IncomeChangeToJson(IncomeChange instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'description': instance.description,
      'isRecurring': instance.isRecurring,
      'label': instance.label,
      'changeType': instance.$type,
    };

ExpenseChange _$ExpenseChangeFromJson(Map<String, dynamic> json) =>
    ExpenseChange(
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      isRecurring: json['isRecurring'] as bool? ?? true,
      label: json['label'] as String? ?? 'Gider',
      $type: json['changeType'] as String?,
    );

Map<String, dynamic> _$ExpenseChangeToJson(ExpenseChange instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'description': instance.description,
      'isRecurring': instance.isRecurring,
      'label': instance.label,
      'changeType': instance.$type,
    };

InvestmentChange _$InvestmentChangeFromJson(Map<String, dynamic> json) =>
    InvestmentChange(
      principal: (json['principal'] as num).toDouble(),
      annualReturnRate: (json['annualReturnRate'] as num).toDouble(),
      termMonths: (json['termMonths'] as num).toInt(),
      isCompound: json['isCompound'] as bool? ?? true,
      label: json['label'] as String? ?? 'Yatırım',
      $type: json['changeType'] as String?,
    );

Map<String, dynamic> _$InvestmentChangeToJson(InvestmentChange instance) =>
    <String, dynamic>{
      'principal': instance.principal,
      'annualReturnRate': instance.annualReturnRate,
      'termMonths': instance.termMonths,
      'isCompound': instance.isCompound,
      'label': instance.label,
      'changeType': instance.$type,
    };
