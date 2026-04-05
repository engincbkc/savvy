// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'planned_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlannedChange {

 String get id; String get parentId;// Income.id or Expense.id
 String get parentType;// 'income' or 'expense'
 double get newAmount;// new amount from effectiveDate
 DateTime get effectiveDate; bool get isGross;// for income: is newAmount gross?
 String? get note; bool get isDeleted; DateTime get createdAt;
/// Create a copy of PlannedChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlannedChangeCopyWith<PlannedChange> get copyWith => _$PlannedChangeCopyWithImpl<PlannedChange>(this as PlannedChange, _$identity);

  /// Serializes this PlannedChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlannedChange&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.parentType, parentType) || other.parentType == parentType)&&(identical(other.newAmount, newAmount) || other.newAmount == newAmount)&&(identical(other.effectiveDate, effectiveDate) || other.effectiveDate == effectiveDate)&&(identical(other.isGross, isGross) || other.isGross == isGross)&&(identical(other.note, note) || other.note == note)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId,parentType,newAmount,effectiveDate,isGross,note,isDeleted,createdAt);

@override
String toString() {
  return 'PlannedChange(id: $id, parentId: $parentId, parentType: $parentType, newAmount: $newAmount, effectiveDate: $effectiveDate, isGross: $isGross, note: $note, isDeleted: $isDeleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PlannedChangeCopyWith<$Res>  {
  factory $PlannedChangeCopyWith(PlannedChange value, $Res Function(PlannedChange) _then) = _$PlannedChangeCopyWithImpl;
@useResult
$Res call({
 String id, String parentId, String parentType, double newAmount, DateTime effectiveDate, bool isGross, String? note, bool isDeleted, DateTime createdAt
});




}
/// @nodoc
class _$PlannedChangeCopyWithImpl<$Res>
    implements $PlannedChangeCopyWith<$Res> {
  _$PlannedChangeCopyWithImpl(this._self, this._then);

  final PlannedChange _self;
  final $Res Function(PlannedChange) _then;

/// Create a copy of PlannedChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentId = null,Object? parentType = null,Object? newAmount = null,Object? effectiveDate = null,Object? isGross = null,Object? note = freezed,Object? isDeleted = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,parentType: null == parentType ? _self.parentType : parentType // ignore: cast_nullable_to_non_nullable
as String,newAmount: null == newAmount ? _self.newAmount : newAmount // ignore: cast_nullable_to_non_nullable
as double,effectiveDate: null == effectiveDate ? _self.effectiveDate : effectiveDate // ignore: cast_nullable_to_non_nullable
as DateTime,isGross: null == isGross ? _self.isGross : isGross // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PlannedChange].
extension PlannedChangePatterns on PlannedChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlannedChange value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlannedChange() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlannedChange value)  $default,){
final _that = this;
switch (_that) {
case _PlannedChange():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlannedChange value)?  $default,){
final _that = this;
switch (_that) {
case _PlannedChange() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parentId,  String parentType,  double newAmount,  DateTime effectiveDate,  bool isGross,  String? note,  bool isDeleted,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlannedChange() when $default != null:
return $default(_that.id,_that.parentId,_that.parentType,_that.newAmount,_that.effectiveDate,_that.isGross,_that.note,_that.isDeleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parentId,  String parentType,  double newAmount,  DateTime effectiveDate,  bool isGross,  String? note,  bool isDeleted,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PlannedChange():
return $default(_that.id,_that.parentId,_that.parentType,_that.newAmount,_that.effectiveDate,_that.isGross,_that.note,_that.isDeleted,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parentId,  String parentType,  double newAmount,  DateTime effectiveDate,  bool isGross,  String? note,  bool isDeleted,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PlannedChange() when $default != null:
return $default(_that.id,_that.parentId,_that.parentType,_that.newAmount,_that.effectiveDate,_that.isGross,_that.note,_that.isDeleted,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlannedChange implements PlannedChange {
  const _PlannedChange({required this.id, required this.parentId, required this.parentType, required this.newAmount, required this.effectiveDate, this.isGross = false, this.note, this.isDeleted = false, required this.createdAt});
  factory _PlannedChange.fromJson(Map<String, dynamic> json) => _$PlannedChangeFromJson(json);

@override final  String id;
@override final  String parentId;
// Income.id or Expense.id
@override final  String parentType;
// 'income' or 'expense'
@override final  double newAmount;
// new amount from effectiveDate
@override final  DateTime effectiveDate;
@override@JsonKey() final  bool isGross;
// for income: is newAmount gross?
@override final  String? note;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime createdAt;

/// Create a copy of PlannedChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlannedChangeCopyWith<_PlannedChange> get copyWith => __$PlannedChangeCopyWithImpl<_PlannedChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlannedChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlannedChange&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.parentType, parentType) || other.parentType == parentType)&&(identical(other.newAmount, newAmount) || other.newAmount == newAmount)&&(identical(other.effectiveDate, effectiveDate) || other.effectiveDate == effectiveDate)&&(identical(other.isGross, isGross) || other.isGross == isGross)&&(identical(other.note, note) || other.note == note)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId,parentType,newAmount,effectiveDate,isGross,note,isDeleted,createdAt);

@override
String toString() {
  return 'PlannedChange(id: $id, parentId: $parentId, parentType: $parentType, newAmount: $newAmount, effectiveDate: $effectiveDate, isGross: $isGross, note: $note, isDeleted: $isDeleted, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PlannedChangeCopyWith<$Res> implements $PlannedChangeCopyWith<$Res> {
  factory _$PlannedChangeCopyWith(_PlannedChange value, $Res Function(_PlannedChange) _then) = __$PlannedChangeCopyWithImpl;
@override @useResult
$Res call({
 String id, String parentId, String parentType, double newAmount, DateTime effectiveDate, bool isGross, String? note, bool isDeleted, DateTime createdAt
});




}
/// @nodoc
class __$PlannedChangeCopyWithImpl<$Res>
    implements _$PlannedChangeCopyWith<$Res> {
  __$PlannedChangeCopyWithImpl(this._self, this._then);

  final _PlannedChange _self;
  final $Res Function(_PlannedChange) _then;

/// Create a copy of PlannedChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentId = null,Object? parentType = null,Object? newAmount = null,Object? effectiveDate = null,Object? isGross = null,Object? note = freezed,Object? isDeleted = null,Object? createdAt = null,}) {
  return _then(_PlannedChange(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,parentType: null == parentType ? _self.parentType : parentType // ignore: cast_nullable_to_non_nullable
as String,newAmount: null == newAmount ? _self.newAmount : newAmount // ignore: cast_nullable_to_non_nullable
as double,effectiveDate: null == effectiveDate ? _self.effectiveDate : effectiveDate // ignore: cast_nullable_to_non_nullable
as DateTime,isGross: null == isGross ? _self.isGross : isGross // ignore: cast_nullable_to_non_nullable
as bool,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
