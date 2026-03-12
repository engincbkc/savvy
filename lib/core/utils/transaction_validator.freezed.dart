// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_validator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ValidationResult<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationResult<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ValidationResult<$T>()';
}


}

/// @nodoc
class $ValidationResultCopyWith<T,$Res>  {
$ValidationResultCopyWith(ValidationResult<T> _, $Res Function(ValidationResult<T>) __);
}


/// Adds pattern-matching-related methods to [ValidationResult].
extension ValidationResultPatterns<T> on ValidationResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ValidationOk<T> value)?  ok,TResult Function( ValidationError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ValidationOk() when ok != null:
return ok(_that);case ValidationError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ValidationOk<T> value)  ok,required TResult Function( ValidationError<T> value)  error,}){
final _that = this;
switch (_that) {
case ValidationOk():
return ok(_that);case ValidationError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ValidationOk<T> value)?  ok,TResult? Function( ValidationError<T> value)?  error,}){
final _that = this;
switch (_that) {
case ValidationOk() when ok != null:
return ok(_that);case ValidationError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T? value)?  ok,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ValidationOk() when ok != null:
return ok(_that.value);case ValidationError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T? value)  ok,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case ValidationOk():
return ok(_that.value);case ValidationError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T? value)?  ok,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case ValidationOk() when ok != null:
return ok(_that.value);case ValidationError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class ValidationOk<T> implements ValidationResult<T> {
  const ValidationOk([this.value]);
  

 final  T? value;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationOkCopyWith<T, ValidationOk<T>> get copyWith => _$ValidationOkCopyWithImpl<T, ValidationOk<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationOk<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'ValidationResult<$T>.ok(value: $value)';
}


}

/// @nodoc
abstract mixin class $ValidationOkCopyWith<T,$Res> implements $ValidationResultCopyWith<T, $Res> {
  factory $ValidationOkCopyWith(ValidationOk<T> value, $Res Function(ValidationOk<T>) _then) = _$ValidationOkCopyWithImpl;
@useResult
$Res call({
 T? value
});




}
/// @nodoc
class _$ValidationOkCopyWithImpl<T,$Res>
    implements $ValidationOkCopyWith<T, $Res> {
  _$ValidationOkCopyWithImpl(this._self, this._then);

  final ValidationOk<T> _self;
  final $Res Function(ValidationOk<T>) _then;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(ValidationOk<T>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}


}

/// @nodoc


class ValidationError<T> implements ValidationResult<T> {
  const ValidationError(this.message);
  

 final  String message;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationErrorCopyWith<T, ValidationError<T>> get copyWith => _$ValidationErrorCopyWithImpl<T, ValidationError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationError<T>&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ValidationResult<$T>.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $ValidationErrorCopyWith<T,$Res> implements $ValidationResultCopyWith<T, $Res> {
  factory $ValidationErrorCopyWith(ValidationError<T> value, $Res Function(ValidationError<T>) _then) = _$ValidationErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ValidationErrorCopyWithImpl<T,$Res>
    implements $ValidationErrorCopyWith<T, $Res> {
  _$ValidationErrorCopyWithImpl(this._self, this._then);

  final ValidationError<T> _self;
  final $Res Function(ValidationError<T>) _then;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ValidationError<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
