// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simulation_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SimulationEntry {

 String get id; String get title; String? get description; SimulationTemplate? get template; String get iconName; String get colorHex; List<SimulationChange> get changes; String? get compareWithId;// Legacy fields — kept for backward compat with old Firestore data
// ignore: deprecated_member_use_from_same_package
 SimulationType? get type; Map<String, dynamic> get parameters; bool get isIncluded; bool get isDeleted; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of SimulationEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimulationEntryCopyWith<SimulationEntry> get copyWith => _$SimulationEntryCopyWithImpl<SimulationEntry>(this as SimulationEntry, _$identity);

  /// Serializes this SimulationEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimulationEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.template, template) || other.template == template)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&const DeepCollectionEquality().equals(other.changes, changes)&&(identical(other.compareWithId, compareWithId) || other.compareWithId == compareWithId)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.parameters, parameters)&&(identical(other.isIncluded, isIncluded) || other.isIncluded == isIncluded)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,template,iconName,colorHex,const DeepCollectionEquality().hash(changes),compareWithId,type,const DeepCollectionEquality().hash(parameters),isIncluded,isDeleted,createdAt,updatedAt);

@override
String toString() {
  return 'SimulationEntry(id: $id, title: $title, description: $description, template: $template, iconName: $iconName, colorHex: $colorHex, changes: $changes, compareWithId: $compareWithId, type: $type, parameters: $parameters, isIncluded: $isIncluded, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SimulationEntryCopyWith<$Res>  {
  factory $SimulationEntryCopyWith(SimulationEntry value, $Res Function(SimulationEntry) _then) = _$SimulationEntryCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? description, SimulationTemplate? template, String iconName, String colorHex, List<SimulationChange> changes, String? compareWithId, SimulationType? type, Map<String, dynamic> parameters, bool isIncluded, bool isDeleted, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$SimulationEntryCopyWithImpl<$Res>
    implements $SimulationEntryCopyWith<$Res> {
  _$SimulationEntryCopyWithImpl(this._self, this._then);

  final SimulationEntry _self;
  final $Res Function(SimulationEntry) _then;

/// Create a copy of SimulationEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? template = freezed,Object? iconName = null,Object? colorHex = null,Object? changes = null,Object? compareWithId = freezed,Object? type = freezed,Object? parameters = null,Object? isIncluded = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as SimulationTemplate?,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self.changes : changes // ignore: cast_nullable_to_non_nullable
as List<SimulationChange>,compareWithId: freezed == compareWithId ? _self.compareWithId : compareWithId // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SimulationType?,parameters: null == parameters ? _self.parameters : parameters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isIncluded: null == isIncluded ? _self.isIncluded : isIncluded // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SimulationEntry].
extension SimulationEntryPatterns on SimulationEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimulationEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimulationEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimulationEntry value)  $default,){
final _that = this;
switch (_that) {
case _SimulationEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimulationEntry value)?  $default,){
final _that = this;
switch (_that) {
case _SimulationEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  SimulationTemplate? template,  String iconName,  String colorHex,  List<SimulationChange> changes,  String? compareWithId,  SimulationType? type,  Map<String, dynamic> parameters,  bool isIncluded,  bool isDeleted,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimulationEntry() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.template,_that.iconName,_that.colorHex,_that.changes,_that.compareWithId,_that.type,_that.parameters,_that.isIncluded,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? description,  SimulationTemplate? template,  String iconName,  String colorHex,  List<SimulationChange> changes,  String? compareWithId,  SimulationType? type,  Map<String, dynamic> parameters,  bool isIncluded,  bool isDeleted,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SimulationEntry():
return $default(_that.id,_that.title,_that.description,_that.template,_that.iconName,_that.colorHex,_that.changes,_that.compareWithId,_that.type,_that.parameters,_that.isIncluded,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? description,  SimulationTemplate? template,  String iconName,  String colorHex,  List<SimulationChange> changes,  String? compareWithId,  SimulationType? type,  Map<String, dynamic> parameters,  bool isIncluded,  bool isDeleted,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SimulationEntry() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.template,_that.iconName,_that.colorHex,_that.changes,_that.compareWithId,_that.type,_that.parameters,_that.isIncluded,_that.isDeleted,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SimulationEntry extends SimulationEntry {
  const _SimulationEntry({required this.id, required this.title, this.description, this.template, this.iconName = 'sparkles', this.colorHex = '#3F83F8', final  List<SimulationChange> changes = const [], this.compareWithId, this.type, final  Map<String, dynamic> parameters = const {}, this.isIncluded = false, this.isDeleted = false, required this.createdAt, this.updatedAt}): _changes = changes,_parameters = parameters,super._();
  factory _SimulationEntry.fromJson(Map<String, dynamic> json) => _$SimulationEntryFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? description;
@override final  SimulationTemplate? template;
@override@JsonKey() final  String iconName;
@override@JsonKey() final  String colorHex;
 final  List<SimulationChange> _changes;
@override@JsonKey() List<SimulationChange> get changes {
  if (_changes is EqualUnmodifiableListView) return _changes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_changes);
}

@override final  String? compareWithId;
// Legacy fields — kept for backward compat with old Firestore data
// ignore: deprecated_member_use_from_same_package
@override final  SimulationType? type;
 final  Map<String, dynamic> _parameters;
@override@JsonKey() Map<String, dynamic> get parameters {
  if (_parameters is EqualUnmodifiableMapView) return _parameters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_parameters);
}

@override@JsonKey() final  bool isIncluded;
@override@JsonKey() final  bool isDeleted;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of SimulationEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimulationEntryCopyWith<_SimulationEntry> get copyWith => __$SimulationEntryCopyWithImpl<_SimulationEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SimulationEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimulationEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.template, template) || other.template == template)&&(identical(other.iconName, iconName) || other.iconName == iconName)&&(identical(other.colorHex, colorHex) || other.colorHex == colorHex)&&const DeepCollectionEquality().equals(other._changes, _changes)&&(identical(other.compareWithId, compareWithId) || other.compareWithId == compareWithId)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._parameters, _parameters)&&(identical(other.isIncluded, isIncluded) || other.isIncluded == isIncluded)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,template,iconName,colorHex,const DeepCollectionEquality().hash(_changes),compareWithId,type,const DeepCollectionEquality().hash(_parameters),isIncluded,isDeleted,createdAt,updatedAt);

@override
String toString() {
  return 'SimulationEntry(id: $id, title: $title, description: $description, template: $template, iconName: $iconName, colorHex: $colorHex, changes: $changes, compareWithId: $compareWithId, type: $type, parameters: $parameters, isIncluded: $isIncluded, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SimulationEntryCopyWith<$Res> implements $SimulationEntryCopyWith<$Res> {
  factory _$SimulationEntryCopyWith(_SimulationEntry value, $Res Function(_SimulationEntry) _then) = __$SimulationEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? description, SimulationTemplate? template, String iconName, String colorHex, List<SimulationChange> changes, String? compareWithId, SimulationType? type, Map<String, dynamic> parameters, bool isIncluded, bool isDeleted, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$SimulationEntryCopyWithImpl<$Res>
    implements _$SimulationEntryCopyWith<$Res> {
  __$SimulationEntryCopyWithImpl(this._self, this._then);

  final _SimulationEntry _self;
  final $Res Function(_SimulationEntry) _then;

/// Create a copy of SimulationEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = freezed,Object? template = freezed,Object? iconName = null,Object? colorHex = null,Object? changes = null,Object? compareWithId = freezed,Object? type = freezed,Object? parameters = null,Object? isIncluded = null,Object? isDeleted = null,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_SimulationEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,template: freezed == template ? _self.template : template // ignore: cast_nullable_to_non_nullable
as SimulationTemplate?,iconName: null == iconName ? _self.iconName : iconName // ignore: cast_nullable_to_non_nullable
as String,colorHex: null == colorHex ? _self.colorHex : colorHex // ignore: cast_nullable_to_non_nullable
as String,changes: null == changes ? _self._changes : changes // ignore: cast_nullable_to_non_nullable
as List<SimulationChange>,compareWithId: freezed == compareWithId ? _self.compareWithId : compareWithId // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as SimulationType?,parameters: null == parameters ? _self._parameters : parameters // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,isIncluded: null == isIncluded ? _self.isIncluded : isIncluded // ignore: cast_nullable_to_non_nullable
as bool,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
