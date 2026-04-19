// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Expense {

 String get id; double get amount; ExpenseCategory get category; ExpenseType get expenseType; String? get subcategory; String? get person; DateTime get date; String? get note; bool get isRecurring; DateTime? get recurringEndDate; bool get isDeleted; DateTime get createdAt;/// Per-month amount overrides for recurring items.
/// Key: "YYYY-MM", Value: override amount for that month.
/// Months not present use the default [amount].
 Map<String, double> get monthlyOverrides;/// true = ödendi (gider ödendi), false = beklemede
 bool get isSettled;
/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseCopyWith<Expense> get copyWith => _$ExpenseCopyWithImpl<Expense>(this as Expense, _$identity);

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.expenseType, expenseType) || other.expenseType == expenseType)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.person, person) || other.person == person)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.monthlyOverrides, monthlyOverrides)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,category,expenseType,subcategory,person,date,note,isRecurring,recurringEndDate,isDeleted,createdAt,const DeepCollectionEquality().hash(monthlyOverrides),isSettled);

@override
String toString() {
  return 'Expense(id: $id, amount: $amount, category: $category, expenseType: $expenseType, subcategory: $subcategory, person: $person, date: $date, note: $note, isRecurring: $isRecurring, recurringEndDate: $recurringEndDate, isDeleted: $isDeleted, createdAt: $createdAt, monthlyOverrides: $monthlyOverrides, isSettled: $isSettled)';
}


}

/// @nodoc
abstract mixin class $ExpenseCopyWith<$Res>  {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) _then) = _$ExpenseCopyWithImpl;
@useResult
$Res call({
 String id, double amount, ExpenseCategory category, ExpenseType expenseType, String? subcategory, String? person, DateTime date, String? note, bool isRecurring, DateTime? recurringEndDate, bool isDeleted, DateTime createdAt, Map<String, double> monthlyOverrides, bool isSettled
});




}
/// @nodoc
class _$ExpenseCopyWithImpl<$Res>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._self, this._then);

  final Expense _self;
  final $Res Function(Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? expenseType = null,Object? subcategory = freezed,Object? person = freezed,Object? date = null,Object? note = freezed,Object? isRecurring = null,Object? recurringEndDate = freezed,Object? isDeleted = null,Object? createdAt = null,Object? monthlyOverrides = null,Object? isSettled = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,expenseType: null == expenseType ? _self.expenseType : expenseType // ignore: cast_nullable_to_non_nullable
as ExpenseType,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,person: freezed == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,monthlyOverrides: null == monthlyOverrides ? _self.monthlyOverrides : monthlyOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Expense].
extension ExpensePatterns on Expense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Expense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Expense value)  $default,){
final _that = this;
switch (_that) {
case _Expense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Expense value)?  $default,){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount,  ExpenseCategory category,  ExpenseType expenseType,  String? subcategory,  String? person,  DateTime date,  String? note,  bool isRecurring,  DateTime? recurringEndDate,  bool isDeleted,  DateTime createdAt,  Map<String, double> monthlyOverrides,  bool isSettled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.expenseType,_that.subcategory,_that.person,_that.date,_that.note,_that.isRecurring,_that.recurringEndDate,_that.isDeleted,_that.createdAt,_that.monthlyOverrides,_that.isSettled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount,  ExpenseCategory category,  ExpenseType expenseType,  String? subcategory,  String? person,  DateTime date,  String? note,  bool isRecurring,  DateTime? recurringEndDate,  bool isDeleted,  DateTime createdAt,  Map<String, double> monthlyOverrides,  bool isSettled)  $default,) {final _that = this;
switch (_that) {
case _Expense():
return $default(_that.id,_that.amount,_that.category,_that.expenseType,_that.subcategory,_that.person,_that.date,_that.note,_that.isRecurring,_that.recurringEndDate,_that.isDeleted,_that.createdAt,_that.monthlyOverrides,_that.isSettled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount,  ExpenseCategory category,  ExpenseType expenseType,  String? subcategory,  String? person,  DateTime date,  String? note,  bool isRecurring,  DateTime? recurringEndDate,  bool isDeleted,  DateTime createdAt,  Map<String, double> monthlyOverrides,  bool isSettled)?  $default,) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.expenseType,_that.subcategory,_that.person,_that.date,_that.note,_that.isRecurring,_that.recurringEndDate,_that.isDeleted,_that.createdAt,_that.monthlyOverrides,_that.isSettled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Expense implements Expense {
  const _Expense({required this.id, required this.amount, required this.category, this.expenseType = ExpenseType.variable, this.subcategory, this.person, required this.date, this.note, this.isRecurring = false, this.recurringEndDate, this.isDeleted = false, required this.createdAt, final  Map<String, double> monthlyOverrides = const {}, this.isSettled = false}): _monthlyOverrides = monthlyOverrides;
  factory _Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

@override final  String id;
@override final  double amount;
@override final  ExpenseCategory category;
@override@JsonKey() final  ExpenseType expenseType;
@override final  String? subcategory;
@override final  String? person;
@override final  DateTime date;
@override final  String? note;
@override@JsonKey() final  bool isRecurring;
@override final  DateTime? recurringEndDate;
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

/// true = ödendi (gider ödendi), false = beklemede
@override@JsonKey() final  bool isSettled;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseCopyWith<_Expense> get copyWith => __$ExpenseCopyWithImpl<_Expense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.expenseType, expenseType) || other.expenseType == expenseType)&&(identical(other.subcategory, subcategory) || other.subcategory == subcategory)&&(identical(other.person, person) || other.person == person)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringEndDate, recurringEndDate) || other.recurringEndDate == recurringEndDate)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._monthlyOverrides, _monthlyOverrides)&&(identical(other.isSettled, isSettled) || other.isSettled == isSettled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,category,expenseType,subcategory,person,date,note,isRecurring,recurringEndDate,isDeleted,createdAt,const DeepCollectionEquality().hash(_monthlyOverrides),isSettled);

@override
String toString() {
  return 'Expense(id: $id, amount: $amount, category: $category, expenseType: $expenseType, subcategory: $subcategory, person: $person, date: $date, note: $note, isRecurring: $isRecurring, recurringEndDate: $recurringEndDate, isDeleted: $isDeleted, createdAt: $createdAt, monthlyOverrides: $monthlyOverrides, isSettled: $isSettled)';
}


}

/// @nodoc
abstract mixin class _$ExpenseCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$ExpenseCopyWith(_Expense value, $Res Function(_Expense) _then) = __$ExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount, ExpenseCategory category, ExpenseType expenseType, String? subcategory, String? person, DateTime date, String? note, bool isRecurring, DateTime? recurringEndDate, bool isDeleted, DateTime createdAt, Map<String, double> monthlyOverrides, bool isSettled
});




}
/// @nodoc
class __$ExpenseCopyWithImpl<$Res>
    implements _$ExpenseCopyWith<$Res> {
  __$ExpenseCopyWithImpl(this._self, this._then);

  final _Expense _self;
  final $Res Function(_Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? expenseType = null,Object? subcategory = freezed,Object? person = freezed,Object? date = null,Object? note = freezed,Object? isRecurring = null,Object? recurringEndDate = freezed,Object? isDeleted = null,Object? createdAt = null,Object? monthlyOverrides = null,Object? isSettled = null,}) {
  return _then(_Expense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,expenseType: null == expenseType ? _self.expenseType : expenseType // ignore: cast_nullable_to_non_nullable
as ExpenseType,subcategory: freezed == subcategory ? _self.subcategory : subcategory // ignore: cast_nullable_to_non_nullable
as String?,person: freezed == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringEndDate: freezed == recurringEndDate ? _self.recurringEndDate : recurringEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,monthlyOverrides: null == monthlyOverrides ? _self._monthlyOverrides : monthlyOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isSettled: null == isSettled ? _self.isSettled : isSettled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
