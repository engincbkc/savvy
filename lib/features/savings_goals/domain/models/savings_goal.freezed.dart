// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingsGoal {

 String get id; String get title; double get targetAmount; double get currentAmount; DateTime? get targetDate; SavingsCategory get category; String get colorHex; String get iconName; GoalStatus get status; DateTime get createdAt;
/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsGoalCopyWith<SavingsGoal> get copyWith => _$SavingsGoalCopyWithImpl<SavingsGoal>(this as SavingsGoal, _$identity);

  /// Serializes this SavingsGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.category, category) || other.category == category)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetAmount,currentAmount,targetDate,category,colorHex,iconName,status,createdAt);

@override
String toString() {
  return 'SavingsGoal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, category: $category, colorHex: $colorHex, iconName: $iconName, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SavingsGoalCopyWith<$Res>  {
  factory $SavingsGoalCopyWith(SavingsGoal value, $Res Function(SavingsGoal) _then) = _$SavingsGoalCopyWithImpl;
@useResult
$Res call({
 String id, String title, double targetAmount, double currentAmount, DateTime? targetDate, SavingsCategory category, String colorHex, String iconName, GoalStatus status, DateTime createdAt
});




}
/// @nodoc
class _$SavingsGoalCopyWithImpl<$Res>
    implements $SavingsGoalCopyWith<$Res> {
  _$SavingsGoalCopyWithImpl(this._self, this._then);

  final SavingsGoal _self;
  final $Res Function(SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? targetAmount = null,Object? currentAmount = null,Object? targetDate = freezed,Object? category = null,Object? colorHex = null,Object? iconName = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SavingsCategory,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoalStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsGoal].
extension SavingsGoalPatterns on SavingsGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsGoal value)  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsGoal value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double targetAmount,  double currentAmount,  DateTime? targetDate,  SavingsCategory category,  String colorHex,  String iconName,  GoalStatus status,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.title,_that.targetAmount,_that.currentAmount,_that.targetDate,_that.category,_that.colorHex,_that.iconName,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double targetAmount,  double currentAmount,  DateTime? targetDate,  SavingsCategory category,  String colorHex,  String iconName,  GoalStatus status,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal():
return $default(_that.id,_that.title,_that.targetAmount,_that.currentAmount,_that.targetDate,_that.category,_that.colorHex,_that.iconName,_that.status,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double targetAmount,  double currentAmount,  DateTime? targetDate,  SavingsCategory category,  String colorHex,  String iconName,  GoalStatus status,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.title,_that.targetAmount,_that.currentAmount,_that.targetDate,_that.category,_that.colorHex,_that.iconName,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsGoal implements SavingsGoal {
  const _SavingsGoal({required this.id, required this.title, required this.targetAmount, this.currentAmount = 0.0, this.targetDate, required this.category, this.colorHex = '#D97706', this.iconName = 'target', this.status = GoalStatus.active, required this.createdAt});
  factory _SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);

@override final  String id;
@override final  String title;
@override final  double targetAmount;
@override@JsonKey() final  double currentAmount;
@override final  DateTime? targetDate;
@override final  SavingsCategory category;
@override@JsonKey() final  String colorHex;
@override@JsonKey() final  String iconName;
@override@JsonKey() final  GoalStatus status;
@override final  DateTime createdAt;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsGoalCopyWith<_SavingsGoal> get copyWith => __$SavingsGoalCopyWithImpl<_SavingsGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsGoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetAmount, targetAmount) || other.targetAmount == targetAmount)&&(identical(other.currentAmount, currentAmount) || other.currentAmount == currentAmount)&&(identical(other.targetDate, targetDate) || other.targetDate == targetDate)&&(identical(other.category, category) || other.category == category)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetAmount,currentAmount,targetDate,category,colorHex,iconName,status,createdAt);

@override
String toString() {
  return 'SavingsGoal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, category: $category, colorHex: $colorHex, iconName: $iconName, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SavingsGoalCopyWith<$Res> implements $SavingsGoalCopyWith<$Res> {
  factory _$SavingsGoalCopyWith(_SavingsGoal value, $Res Function(_SavingsGoal) _then) = __$SavingsGoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double targetAmount, double currentAmount, DateTime? targetDate, SavingsCategory category, String colorHex, String iconName, GoalStatus status, DateTime createdAt
});




}
/// @nodoc
class __$SavingsGoalCopyWithImpl<$Res>
    implements _$SavingsGoalCopyWith<$Res> {
  __$SavingsGoalCopyWithImpl(this._self, this._then);

  final _SavingsGoal _self;
  final $Res Function(_SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? targetAmount = null,Object? currentAmount = null,Object? targetDate = freezed,Object? category = null,Object? colorHex = null,Object? iconName = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_SavingsGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetAmount: null == targetAmount ? _self.targetAmount : targetAmount // ignore: cast_nullable_to_non_nullable
as double,currentAmount: null == currentAmount ? _self.currentAmount : currentAmount // ignore: cast_nullable_to_non_nullable
as double,targetDate: freezed == targetDate ? _self.targetDate : targetDate // ignore: cast_nullable_to_non_nullable
as DateTime?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as SavingsCategory,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GoalStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
