// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthSummary {

 String get yearMonth;// "2025-03"
 double get totalIncome; double get totalExpense; double get totalSavings; double get netBalance; double get carryOver; double get netWithCarryOver; double get savingsRate; double get expenseRate; int get healthScore; DateTime get updatedAt;
/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthSummaryCopyWith<MonthSummary> get copyWith => _$MonthSummaryCopyWithImpl<MonthSummary>(this as MonthSummary, _$identity);

  /// Serializes this MonthSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthSummary&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.totalSavings, totalSavings) || other.totalSavings == totalSavings)&&(identical(other.netBalance, netBalance) || other.netBalance == netBalance)&&(identical(other.carryOver, carryOver) || other.carryOver == carryOver)&&(identical(other.netWithCarryOver, netWithCarryOver) || other.netWithCarryOver == netWithCarryOver)&&(identical(other.savingsRate, savingsRate) || other.savingsRate == savingsRate)&&(identical(other.expenseRate, expenseRate) || other.expenseRate == expenseRate)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,yearMonth,totalIncome,totalExpense,totalSavings,netBalance,carryOver,netWithCarryOver,savingsRate,expenseRate,healthScore,updatedAt);

@override
String toString() {
  return 'MonthSummary(yearMonth: $yearMonth, totalIncome: $totalIncome, totalExpense: $totalExpense, totalSavings: $totalSavings, netBalance: $netBalance, carryOver: $carryOver, netWithCarryOver: $netWithCarryOver, savingsRate: $savingsRate, expenseRate: $expenseRate, healthScore: $healthScore, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MonthSummaryCopyWith<$Res>  {
  factory $MonthSummaryCopyWith(MonthSummary value, $Res Function(MonthSummary) _then) = _$MonthSummaryCopyWithImpl;
@useResult
$Res call({
 String yearMonth, double totalIncome, double totalExpense, double totalSavings, double netBalance, double carryOver, double netWithCarryOver, double savingsRate, double expenseRate, int healthScore, DateTime updatedAt
});




}
/// @nodoc
class _$MonthSummaryCopyWithImpl<$Res>
    implements $MonthSummaryCopyWith<$Res> {
  _$MonthSummaryCopyWithImpl(this._self, this._then);

  final MonthSummary _self;
  final $Res Function(MonthSummary) _then;

/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? yearMonth = null,Object? totalIncome = null,Object? totalExpense = null,Object? totalSavings = null,Object? netBalance = null,Object? carryOver = null,Object? netWithCarryOver = null,Object? savingsRate = null,Object? expenseRate = null,Object? healthScore = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,totalSavings: null == totalSavings ? _self.totalSavings : totalSavings // ignore: cast_nullable_to_non_nullable
as double,netBalance: null == netBalance ? _self.netBalance : netBalance // ignore: cast_nullable_to_non_nullable
as double,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as double,netWithCarryOver: null == netWithCarryOver ? _self.netWithCarryOver : netWithCarryOver // ignore: cast_nullable_to_non_nullable
as double,savingsRate: null == savingsRate ? _self.savingsRate : savingsRate // ignore: cast_nullable_to_non_nullable
as double,expenseRate: null == expenseRate ? _self.expenseRate : expenseRate // ignore: cast_nullable_to_non_nullable
as double,healthScore: null == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthSummary].
extension MonthSummaryPatterns on MonthSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthSummary value)  $default,){
final _that = this;
switch (_that) {
case _MonthSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String yearMonth,  double totalIncome,  double totalExpense,  double totalSavings,  double netBalance,  double carryOver,  double netWithCarryOver,  double savingsRate,  double expenseRate,  int healthScore,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
return $default(_that.yearMonth,_that.totalIncome,_that.totalExpense,_that.totalSavings,_that.netBalance,_that.carryOver,_that.netWithCarryOver,_that.savingsRate,_that.expenseRate,_that.healthScore,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String yearMonth,  double totalIncome,  double totalExpense,  double totalSavings,  double netBalance,  double carryOver,  double netWithCarryOver,  double savingsRate,  double expenseRate,  int healthScore,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MonthSummary():
return $default(_that.yearMonth,_that.totalIncome,_that.totalExpense,_that.totalSavings,_that.netBalance,_that.carryOver,_that.netWithCarryOver,_that.savingsRate,_that.expenseRate,_that.healthScore,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String yearMonth,  double totalIncome,  double totalExpense,  double totalSavings,  double netBalance,  double carryOver,  double netWithCarryOver,  double savingsRate,  double expenseRate,  int healthScore,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MonthSummary() when $default != null:
return $default(_that.yearMonth,_that.totalIncome,_that.totalExpense,_that.totalSavings,_that.netBalance,_that.carryOver,_that.netWithCarryOver,_that.savingsRate,_that.expenseRate,_that.healthScore,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthSummary implements MonthSummary {
  const _MonthSummary({required this.yearMonth, this.totalIncome = 0.0, this.totalExpense = 0.0, this.totalSavings = 0.0, this.netBalance = 0.0, this.carryOver = 0.0, this.netWithCarryOver = 0.0, this.savingsRate = 0.0, this.expenseRate = 0.0, this.healthScore = 0, required this.updatedAt});
  factory _MonthSummary.fromJson(Map<String, dynamic> json) => _$MonthSummaryFromJson(json);

@override final  String yearMonth;
// "2025-03"
@override@JsonKey() final  double totalIncome;
@override@JsonKey() final  double totalExpense;
@override@JsonKey() final  double totalSavings;
@override@JsonKey() final  double netBalance;
@override@JsonKey() final  double carryOver;
@override@JsonKey() final  double netWithCarryOver;
@override@JsonKey() final  double savingsRate;
@override@JsonKey() final  double expenseRate;
@override@JsonKey() final  int healthScore;
@override final  DateTime updatedAt;

/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthSummaryCopyWith<_MonthSummary> get copyWith => __$MonthSummaryCopyWithImpl<_MonthSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthSummary&&(identical(other.yearMonth, yearMonth) || other.yearMonth == yearMonth)&&(identical(other.totalIncome, totalIncome) || other.totalIncome == totalIncome)&&(identical(other.totalExpense, totalExpense) || other.totalExpense == totalExpense)&&(identical(other.totalSavings, totalSavings) || other.totalSavings == totalSavings)&&(identical(other.netBalance, netBalance) || other.netBalance == netBalance)&&(identical(other.carryOver, carryOver) || other.carryOver == carryOver)&&(identical(other.netWithCarryOver, netWithCarryOver) || other.netWithCarryOver == netWithCarryOver)&&(identical(other.savingsRate, savingsRate) || other.savingsRate == savingsRate)&&(identical(other.expenseRate, expenseRate) || other.expenseRate == expenseRate)&&(identical(other.healthScore, healthScore) || other.healthScore == healthScore)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,yearMonth,totalIncome,totalExpense,totalSavings,netBalance,carryOver,netWithCarryOver,savingsRate,expenseRate,healthScore,updatedAt);

@override
String toString() {
  return 'MonthSummary(yearMonth: $yearMonth, totalIncome: $totalIncome, totalExpense: $totalExpense, totalSavings: $totalSavings, netBalance: $netBalance, carryOver: $carryOver, netWithCarryOver: $netWithCarryOver, savingsRate: $savingsRate, expenseRate: $expenseRate, healthScore: $healthScore, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MonthSummaryCopyWith<$Res> implements $MonthSummaryCopyWith<$Res> {
  factory _$MonthSummaryCopyWith(_MonthSummary value, $Res Function(_MonthSummary) _then) = __$MonthSummaryCopyWithImpl;
@override @useResult
$Res call({
 String yearMonth, double totalIncome, double totalExpense, double totalSavings, double netBalance, double carryOver, double netWithCarryOver, double savingsRate, double expenseRate, int healthScore, DateTime updatedAt
});




}
/// @nodoc
class __$MonthSummaryCopyWithImpl<$Res>
    implements _$MonthSummaryCopyWith<$Res> {
  __$MonthSummaryCopyWithImpl(this._self, this._then);

  final _MonthSummary _self;
  final $Res Function(_MonthSummary) _then;

/// Create a copy of MonthSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? yearMonth = null,Object? totalIncome = null,Object? totalExpense = null,Object? totalSavings = null,Object? netBalance = null,Object? carryOver = null,Object? netWithCarryOver = null,Object? savingsRate = null,Object? expenseRate = null,Object? healthScore = null,Object? updatedAt = null,}) {
  return _then(_MonthSummary(
yearMonth: null == yearMonth ? _self.yearMonth : yearMonth // ignore: cast_nullable_to_non_nullable
as String,totalIncome: null == totalIncome ? _self.totalIncome : totalIncome // ignore: cast_nullable_to_non_nullable
as double,totalExpense: null == totalExpense ? _self.totalExpense : totalExpense // ignore: cast_nullable_to_non_nullable
as double,totalSavings: null == totalSavings ? _self.totalSavings : totalSavings // ignore: cast_nullable_to_non_nullable
as double,netBalance: null == netBalance ? _self.netBalance : netBalance // ignore: cast_nullable_to_non_nullable
as double,carryOver: null == carryOver ? _self.carryOver : carryOver // ignore: cast_nullable_to_non_nullable
as double,netWithCarryOver: null == netWithCarryOver ? _self.netWithCarryOver : netWithCarryOver // ignore: cast_nullable_to_non_nullable
as double,savingsRate: null == savingsRate ? _self.savingsRate : savingsRate // ignore: cast_nullable_to_non_nullable
as double,expenseRate: null == expenseRate ? _self.expenseRate : expenseRate // ignore: cast_nullable_to_non_nullable
as double,healthScore: null == healthScore ? _self.healthScore : healthScore // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
