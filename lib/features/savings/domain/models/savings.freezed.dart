// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Savings {

 String get id; double get amount; SavingsCategory get category; String? get goalId; String? get note; DateTime get date; SavingsStatus get status; bool get isDeleted; DateTime get createdAt;
/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsCopyWith<Savings> get copyWith => _$SavingsCopyWithImpl<Savings>(this as Savings, _$identity);

  /// Serializes this Savings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Savings&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.note, note) || other.note == note)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,category,goalId,note,date,status,isDeleted,createdAt);

@override
String toString() {
  return 'Savings(id: $id, amount: $amount, category: $category, goalId: $goalId, note: $note, date: $date, status: $status, isDeleted: $isDeleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SavingsCopyWith<$Res>  {
  factory $SavingsCopyWith(Savings value, $Res Function(Savings) _then) = _$SavingsCopyWithImpl;
@useResult
$Res call({
 String id, double amount, SavingsCategory category, String? goalId, String? note, DateTime date, SavingsStatus status, bool isDeleted, DateTime createdAt
});




}
/// @nodoc
class _$SavingsCopyWithImpl<$Res>
    implements $SavingsCopyWith<$Res> {
  _$SavingsCopyWithImpl(this._self, this._then);

  final Savings _self;
  final $Res Function(Savings) _then;

/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? goalId = freezed,Object? note = freezed,Object? date = null,Object? status = null,Object? isDeleted = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SavingsCategory,goalId: freezed == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SavingsStatus,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Savings].
extension SavingsPatterns on Savings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Savings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Savings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Savings value)  $default,){
final _that = this;
switch (_that) {
case _Savings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Savings value)?  $default,){
final _that = this;
switch (_that) {
case _Savings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double amount,  SavingsCategory category,  String? goalId,  String? note,  DateTime date,  SavingsStatus status,  bool isDeleted,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Savings() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.goalId,_that.note,_that.date,_that.status,_that.isDeleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double amount,  SavingsCategory category,  String? goalId,  String? note,  DateTime date,  SavingsStatus status,  bool isDeleted,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Savings():
return $default(_that.id,_that.amount,_that.category,_that.goalId,_that.note,_that.date,_that.status,_that.isDeleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double amount,  SavingsCategory category,  String? goalId,  String? note,  DateTime date,  SavingsStatus status,  bool isDeleted,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Savings() when $default != null:
return $default(_that.id,_that.amount,_that.category,_that.goalId,_that.note,_that.date,_that.status,_that.isDeleted,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Savings implements Savings {
  const _Savings({required this.id, required this.amount, required this.category, this.goalId, this.note, required this.date, this.status = SavingsStatus.active, this.isDeleted = false, required this.createdAt});
  factory _Savings.fromJson(Map<String, dynamic> json) => _$SavingsFromJson(json);

@override final  String id;
@override final  double amount;
@override final  SavingsCategory category;
@override final  String? goalId;
@override final  String? note;
@override final  DateTime date;
@override@JsonKey() final  SavingsStatus status;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime createdAt;

/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsCopyWith<_Savings> get copyWith => __$SavingsCopyWithImpl<_Savings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Savings&&(identical(other.id, id) || other.id == id)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.goalId, goalId) || other.goalId == goalId)&&(identical(other.note, note) || other.note == note)&&(identical(other.date, date) || other.date == date)&&(identical(other.status, status) || other.status == status)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,amount,category,goalId,note,date,status,isDeleted,createdAt);

@override
String toString() {
  return 'Savings(id: $id, amount: $amount, category: $category, goalId: $goalId, note: $note, date: $date, status: $status, isDeleted: $isDeleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SavingsCopyWith<$Res> implements $SavingsCopyWith<$Res> {
  factory _$SavingsCopyWith(_Savings value, $Res Function(_Savings) _then) = __$SavingsCopyWithImpl;
@override @useResult
$Res call({
 String id, double amount, SavingsCategory category, String? goalId, String? note, DateTime date, SavingsStatus status, bool isDeleted, DateTime createdAt
});




}
/// @nodoc
class __$SavingsCopyWithImpl<$Res>
    implements _$SavingsCopyWith<$Res> {
  __$SavingsCopyWithImpl(this._self, this._then);

  final _Savings _self;
  final $Res Function(_Savings) _then;

/// Create a copy of Savings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? amount = null,Object? category = null,Object? goalId = freezed,Object? note = freezed,Object? date = null,Object? status = null,Object? isDeleted = null,Object? createdAt = null,}) {
  return _then(_Savings(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SavingsCategory,goalId: freezed == goalId ? _self.goalId : goalId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SavingsStatus,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
