// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_limit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetLimit {

 String get id; ExpenseCategory get category; double get monthlyLimit; bool get isActive; DateTime get createdAt; bool get isDeleted;
/// Create a copy of BudgetLimit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetLimitCopyWith<BudgetLimit> get copyWith => _$BudgetLimitCopyWithImpl<BudgetLimit>(this as BudgetLimit, _$identity);

  /// Serializes this BudgetLimit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetLimit&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,monthlyLimit,isActive,createdAt,isDeleted);

@override
String toString() {
  return 'BudgetLimit(id: $id, category: $category, monthlyLimit: $monthlyLimit, isActive: $isActive, createdAt: $createdAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $BudgetLimitCopyWith<$Res>  {
  factory $BudgetLimitCopyWith(BudgetLimit value, $Res Function(BudgetLimit) _then) = _$BudgetLimitCopyWithImpl;
@useResult
$Res call({
 String id, ExpenseCategory category, double monthlyLimit, bool isActive, DateTime createdAt, bool isDeleted
});




}
/// @nodoc
class _$BudgetLimitCopyWithImpl<$Res>
    implements $BudgetLimitCopyWith<$Res> {
  _$BudgetLimitCopyWithImpl(this._self, this._then);

  final BudgetLimit _self;
  final $Res Function(BudgetLimit) _then;

/// Create a copy of BudgetLimit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? monthlyLimit = null,Object? isActive = null,Object? createdAt = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetLimit].
extension BudgetLimitPatterns on BudgetLimit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetLimit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetLimit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetLimit value)  $default,){
final _that = this;
switch (_that) {
case _BudgetLimit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetLimit value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetLimit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ExpenseCategory category,  double monthlyLimit,  bool isActive,  DateTime createdAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetLimit() when $default != null:
return $default(_that.id,_that.category,_that.monthlyLimit,_that.isActive,_that.createdAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ExpenseCategory category,  double monthlyLimit,  bool isActive,  DateTime createdAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _BudgetLimit():
return $default(_that.id,_that.category,_that.monthlyLimit,_that.isActive,_that.createdAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ExpenseCategory category,  double monthlyLimit,  bool isActive,  DateTime createdAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _BudgetLimit() when $default != null:
return $default(_that.id,_that.category,_that.monthlyLimit,_that.isActive,_that.createdAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetLimit implements BudgetLimit {
  const _BudgetLimit({required this.id, required this.category, required this.monthlyLimit, this.isActive = true, required this.createdAt, this.isDeleted = false});
  factory _BudgetLimit.fromJson(Map<String, dynamic> json) => _$BudgetLimitFromJson(json);

@override final  String id;
@override final  ExpenseCategory category;
@override final  double monthlyLimit;
@override@JsonKey() final  bool isActive;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of BudgetLimit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetLimitCopyWith<_BudgetLimit> get copyWith => __$BudgetLimitCopyWithImpl<_BudgetLimit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetLimitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetLimit&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,monthlyLimit,isActive,createdAt,isDeleted);

@override
String toString() {
  return 'BudgetLimit(id: $id, category: $category, monthlyLimit: $monthlyLimit, isActive: $isActive, createdAt: $createdAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$BudgetLimitCopyWith<$Res> implements $BudgetLimitCopyWith<$Res> {
  factory _$BudgetLimitCopyWith(_BudgetLimit value, $Res Function(_BudgetLimit) _then) = __$BudgetLimitCopyWithImpl;
@override @useResult
$Res call({
 String id, ExpenseCategory category, double monthlyLimit, bool isActive, DateTime createdAt, bool isDeleted
});




}
/// @nodoc
class __$BudgetLimitCopyWithImpl<$Res>
    implements _$BudgetLimitCopyWith<$Res> {
  __$BudgetLimitCopyWithImpl(this._self, this._then);

  final _BudgetLimit _self;
  final $Res Function(_BudgetLimit) _then;

/// Create a copy of BudgetLimit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? monthlyLimit = null,Object? isActive = null,Object? createdAt = null,Object? isDeleted = null,}) {
  return _then(_BudgetLimit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
