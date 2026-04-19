// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Income {

 String get id; double get amount; IncomeCategory get category; String? get person; String? get source; DateTime get date; String? get note; bool get isRecurring; DateTime? get recurringEndDate;/// true ise [amount] brüt tutardır; net, ay bazında hesaplanır.
 bool get isGross; bool get isDeleted; DateTime get createdAt;/// Per-month amount overrides for recurring items.
/// Key: "YYYY-MM", Value: override amount for that month.
/// Months not present use the default [amount].
 Map<String, double> get monthlyOverrides;/// true = alındı (gelir tahsil edildi), false = beklemede.
/// Tek seferlik işlemler için kullanılır.
 bool get isSettled;/// Recurring işlemlerin ay bazlı settled durumu.
/// Key: "YYYY-MM", Value: true = alındı.
/// Map'te olmayan aylar isSettled default'unu kullanır.
 Map<String, bool> get settledMonths;
/// Create a copy of Income
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomeCopyWith<Income> get copyWith => _$IncomeCopyWithImpl<Income>(this as Income, _$identity);

  /// Serializes this Income to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Income&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.person, person) || other.person == person)&&(identical(other.source, source) || other.source == source)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.isGross, isGross) || other.isGross == isGross)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.monthlyOverrides, monthlyOverrides)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&const DeepCollectionEquality().equals(other.settledMonths, settledMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,category,person,source,date,note,isRecurring,recurringEndDate,isGross,isDeleted,createdAt,const DeepCollectionEquality().hash(monthlyOverrides),isSettled,const DeepCollectionEquality().hash(settledMonths));

@override
String toString() {
  return 'Income(id: $id, amount: $amount, category: $category, person: $person, source: $source, date: $date, note: $note, isRecurring: $isRecurring, recurringEndDate: $recurringEndDate, isGross: $isGross, isDeleted: $isDeleted, createdAt: $createdAt, monthlyOverrides: $monthlyOverrides, isSettled: $isSettled, settledMonths: $settledMonths)';
}


}

/// @nodoc
abstract mixin class $IncomeCopyWith<$Res>  {
  factory $IncomeCopyWith(Income value, $Res Function(Income) _then) = _$IncomeCopyWithImpl;
@useResult
$Res call({
 String id, double amount, IncomeCategory category, String? person, String? source, DateTime date, String? note, bool isRecurring, DateTime? recurringEndDate, bool isGross, bool isDeleted, DateTime createdAt, Map<String, double> monthlyOverrides, bool isSettled, Map<String, bool> settledMonths
});




}
/// @nodoc
class _$IncomeCopyWithImpl<$Res>
    implements $IncomeCopyWith<$Res> {
  _$IncomeCopyWithImpl(this._self, this._then);

  final Income _self;
  final $Res Function(Income) _then;

/// Create a copy of Income
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? person = freezed,Object? source = freezed,Object? date = null,Object? note = freezed,Object? isRecurring = null,Object? recurringEndDate = freezed,Object? isGross = null,Object? isDeleted = null,Object? createdAt = null,Object? monthlyOverrides = null,Object? isSettled = null,Object? settledMonths = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as IncomeCategory,person: freezed == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isGross: null == isGross ? _self.isGross : isGross // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,monthlyOverrides: null == monthlyOverrides ? _self.monthlyOverrides : monthlyOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,settledMonths: null == settledMonths ? _self.settledMonths : settledMonths // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}

}


/// Adds pattern-matching-related methods to [Income].
extension IncomePatterns on Income {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Income value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Income() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Income value)  $default,){
final _that = this;
switch (_that) {
case _Income():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Income value)?  $default,){
final _that = this;
switch (_that) {
case _Income() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount,  IncomeCategory category,  String? person,  String? source,  DateTime date,  String? note,  bool isRecurring,  DateTime? recurringEndDate,  bool isGross,  bool isDeleted,  DateTime createdAt,  Map<String, double> monthlyOverrides,  bool isSettled,  Map<String, bool> settledMonths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Income() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.person,_that.source,_that.date,_that.note,_that.isRecurring,_that.recurringEndDate,_that.isGross,_that.isDeleted,_that.createdAt,_that.monthlyOverrides,_that.isSettled,_that.settledMonths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount,  IncomeCategory category,  String? person,  String? source,  DateTime date,  String? note,  bool isRecurring,  DateTime? recurringEndDate,  bool isGross,  bool isDeleted,  DateTime createdAt,  Map<String, double> monthlyOverrides,  bool isSettled,  Map<String, bool> settledMonths)  $default,) {final _that = this;
switch (_that) {
case _Income():
return $default(_that.id,_that.amount,_that.category,_that.person,_that.source,_that.date,_that.note,_that.isRecurring,_that.recurringEndDate,_that.isGross,_that.isDeleted,_that.createdAt,_that.monthlyOverrides,_that.isSettled,_that.settledMonths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount,  IncomeCategory category,  String? person,  String? source,  DateTime date,  String? note,  bool isRecurring,  DateTime? recurringEndDate,  bool isGross,  bool isDeleted,  DateTime createdAt,  Map<String, double> monthlyOverrides,  bool isSettled,  Map<String, bool> settledMonths)?  $default,) {final _that = this;
switch (_that) {
case _Income() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.person,_that.source,_that.date,_that.note,_that.isRecurring,_that.recurringEndDate,_that.isGross,_that.isDeleted,_that.createdAt,_that.monthlyOverrides,_that.isSettled,_that.settledMonths);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Income implements Income {
  const _Income({required this.id, required this.amount, required this.category, this.person, this.source, required this.date, this.note, this.isRecurring = false, this.recurringEndDate, this.isGross = false, this.isDeleted = false, required this.createdAt, final  Map<String, double> monthlyOverrides = const {}, this.isSettled = false, final  Map<String, bool> settledMonths = const {}}): _monthlyOverrides = monthlyOverrides,_settledMonths = settledMonths;
  factory _Income.fromJson(Map<String, dynamic> json) => _$IncomeFromJson(json);

@override final  String id;
@override final  double amount;
@override final  IncomeCategory category;
@override final  String? person;
@override final  String? source;
@override final  DateTime date;
@override final  String? note;
@override@JsonKey() final  bool isRecurring;
@override final  DateTime? recurringEndDate;
/// true ise [amount] brüt tutardır; net, ay bazında hesaplanır.
@override@JsonKey() final  bool isGross;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime createdAt;
/// Per-month amount overrides for recurring items.
/// Key: "YYYY-MM", Value: override amount for that month.
/// Months not present use the default [amount].
 final  Map<String, double> _monthlyOverrides;
/// Per-month amount overrides for recurring items.
/// Key: "YYYY-MM", Value: override amount for that month.
/// Months not present use the default [amount].
@override@JsonKey() Map<String, double> get monthlyOverrides {
  if (_monthlyOverrides is EqualUnmodifiableMapView) return _monthlyOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_monthlyOverrides);
}

/// true = alındı (gelir tahsil edildi), false = beklemede.
/// Tek seferlik işlemler için kullanılır.
@override@JsonKey() final  bool isSettled;
/// Recurring işlemlerin ay bazlı settled durumu.
/// Key: "YYYY-MM", Value: true = alındı.
/// Map'te olmayan aylar isSettled default'unu kullanır.
 final  Map<String, bool> _settledMonths;
/// Recurring işlemlerin ay bazlı settled durumu.
/// Key: "YYYY-MM", Value: true = alındı.
/// Map'te olmayan aylar isSettled default'unu kullanır.
@override@JsonKey() Map<String, bool> get settledMonths {
  if (_settledMonths is EqualUnmodifiableMapView) return _settledMonths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settledMonths);
}


/// Create a copy of Income
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncomeCopyWith<_Income> get copyWith => __$IncomeCopyWithImpl<_Income>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IncomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Income&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.person, person) || other.person == person)&&(identical(other.source, source) || other.source == source)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.isGross, isGross) || other.isGross == isGross)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._monthlyOverrides, _monthlyOverrides)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled)&&const DeepCollectionEquality().equals(other._settledMonths, _settledMonths));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,category,person,source,date,note,isRecurring,recurringEndDate,isGross,isDeleted,createdAt,const DeepCollectionEquality().hash(_monthlyOverrides),isSettled,const DeepCollectionEquality().hash(_settledMonths));

@override
String toString() {
  return 'Income(id: $id, amount: $amount, category: $category, person: $person, source: $source, date: $date, note: $note, isRecurring: $isRecurring, recurringEndDate: $recurringEndDate, isGross: $isGross, isDeleted: $isDeleted, createdAt: $createdAt, monthlyOverrides: $monthlyOverrides, isSettled: $isSettled, settledMonths: $settledMonths)';
}


}

/// @nodoc
abstract mixin class _$IncomeCopyWith<$Res> implements $IncomeCopyWith<$Res> {
  factory _$IncomeCopyWith(_Income value, $Res Function(_Income) _then) = __$IncomeCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount, IncomeCategory category, String? person, String? source, DateTime date, String? note, bool isRecurring, DateTime? recurringEndDate, bool isGross, bool isDeleted, DateTime createdAt, Map<String, double> monthlyOverrides, bool isSettled, Map<String, bool> settledMonths
});




}
/// @nodoc
class __$IncomeCopyWithImpl<$Res>
    implements _$IncomeCopyWith<$Res> {
  __$IncomeCopyWithImpl(this._self, this._then);

  final _Income _self;
  final $Res Function(_Income) _then;

/// Create a copy of Income
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? person = freezed,Object? source = freezed,Object? date = null,Object? note = freezed,Object? isRecurring = null,Object? recurringEndDate = freezed,Object? isGross = null,Object? isDeleted = null,Object? createdAt = null,Object? monthlyOverrides = null,Object? isSettled = null,Object? settledMonths = null,}) {
  return _then(_Income(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as IncomeCategory,person: freezed == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as String?,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isGross: null == isGross ? _self.isGross : isGross // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,monthlyOverrides: null == monthlyOverrides ? _self._monthlyOverrides : monthlyOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,settledMonths: null == settledMonths ? _self._settledMonths : settledMonths // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,
  ));
}


}

// dart format on
