// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simulation_change.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
SimulationChange _$SimulationChangeFromJson(
  Map<String, dynamic> json
) {
        switch (json['changeType']) {
                  case 'credit':
          return CreditChange.fromJson(
            json
          );
                case 'housing':
          return HousingChange.fromJson(
            json
          );
                case 'car':
          return CarChange.fromJson(
            json
          );
                case 'rentChange':
          return RentChangeChange.fromJson(
            json
          );
                case 'salaryChange':
          return SalaryChangeChange.fromJson(
            json
          );
                case 'income':
          return IncomeChange.fromJson(
            json
          );
                case 'expense':
          return ExpenseChange.fromJson(
            json
          );
                case 'investment':
          return InvestmentChange.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'changeType',
  'SimulationChange',
  'Invalid union type "${json['changeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$SimulationChange {

// e.g. 25.0 = %25 per year
 String get label;
/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimulationChangeCopyWith<SimulationChange> get copyWith => _$SimulationChangeCopyWithImpl<SimulationChange>(this as SimulationChange, _$identity);

  /// Serializes this SimulationChange to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimulationChange&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label);

@override
String toString() {
  return 'SimulationChange(label: $label)';
}


}

/// @nodoc
abstract mixin class $SimulationChangeCopyWith<$Res>  {
  factory $SimulationChangeCopyWith(SimulationChange value, $Res Function(SimulationChange) _then) = _$SimulationChangeCopyWithImpl;
@useResult
$Res call({
 String label
});




}
/// @nodoc
class _$SimulationChangeCopyWithImpl<$Res>
    implements $SimulationChangeCopyWith<$Res> {
  _$SimulationChangeCopyWithImpl(this._self, this._then);

  final SimulationChange _self;
  final $Res Function(SimulationChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SimulationChange].
extension SimulationChangePatterns on SimulationChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreditChange value)?  credit,TResult Function( HousingChange value)?  housing,TResult Function( CarChange value)?  car,TResult Function( RentChangeChange value)?  rentChange,TResult Function( SalaryChangeChange value)?  salaryChange,TResult Function( IncomeChange value)?  income,TResult Function( ExpenseChange value)?  expense,TResult Function( InvestmentChange value)?  investment,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreditChange() when credit != null:
return credit(_that);case HousingChange() when housing != null:
return housing(_that);case CarChange() when car != null:
return car(_that);case RentChangeChange() when rentChange != null:
return rentChange(_that);case SalaryChangeChange() when salaryChange != null:
return salaryChange(_that);case IncomeChange() when income != null:
return income(_that);case ExpenseChange() when expense != null:
return expense(_that);case InvestmentChange() when investment != null:
return investment(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreditChange value)  credit,required TResult Function( HousingChange value)  housing,required TResult Function( CarChange value)  car,required TResult Function( RentChangeChange value)  rentChange,required TResult Function( SalaryChangeChange value)  salaryChange,required TResult Function( IncomeChange value)  income,required TResult Function( ExpenseChange value)  expense,required TResult Function( InvestmentChange value)  investment,}){
final _that = this;
switch (_that) {
case CreditChange():
return credit(_that);case HousingChange():
return housing(_that);case CarChange():
return car(_that);case RentChangeChange():
return rentChange(_that);case SalaryChangeChange():
return salaryChange(_that);case IncomeChange():
return income(_that);case ExpenseChange():
return expense(_that);case InvestmentChange():
return investment(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreditChange value)?  credit,TResult? Function( HousingChange value)?  housing,TResult? Function( CarChange value)?  car,TResult? Function( RentChangeChange value)?  rentChange,TResult? Function( SalaryChangeChange value)?  salaryChange,TResult? Function( IncomeChange value)?  income,TResult? Function( ExpenseChange value)?  expense,TResult? Function( InvestmentChange value)?  investment,}){
final _that = this;
switch (_that) {
case CreditChange() when credit != null:
return credit(_that);case HousingChange() when housing != null:
return housing(_that);case CarChange() when car != null:
return car(_that);case RentChangeChange() when rentChange != null:
return rentChange(_that);case SalaryChangeChange() when salaryChange != null:
return salaryChange(_that);case IncomeChange() when income != null:
return income(_that);case ExpenseChange() when expense != null:
return expense(_that);case InvestmentChange() when investment != null:
return investment(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double principal,  double annualRate,  int termMonths,  String label)?  credit,TResult Function( double price,  double downPayment,  double annualRate,  int termMonths,  double monthlyExtras,  String label)?  housing,TResult Function( double price,  double downPayment,  double annualRate,  int termMonths,  double monthlyRunningCosts,  String label)?  car,TResult Function( double currentRent,  double newRent,  double annualIncreaseRate,  String label)?  rentChange,TResult Function( double currentGross,  double newGross,  String label)?  salaryChange,TResult Function( double amount,  String description,  bool isRecurring,  String label)?  income,TResult Function( double amount,  String description,  bool isRecurring,  String label)?  expense,TResult Function( double principal,  double annualReturnRate,  int termMonths,  bool isCompound,  String label)?  investment,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreditChange() when credit != null:
return credit(_that.principal,_that.annualRate,_that.termMonths,_that.label);case HousingChange() when housing != null:
return housing(_that.price,_that.downPayment,_that.annualRate,_that.termMonths,_that.monthlyExtras,_that.label);case CarChange() when car != null:
return car(_that.price,_that.downPayment,_that.annualRate,_that.termMonths,_that.monthlyRunningCosts,_that.label);case RentChangeChange() when rentChange != null:
return rentChange(_that.currentRent,_that.newRent,_that.annualIncreaseRate,_that.label);case SalaryChangeChange() when salaryChange != null:
return salaryChange(_that.currentGross,_that.newGross,_that.label);case IncomeChange() when income != null:
return income(_that.amount,_that.description,_that.isRecurring,_that.label);case ExpenseChange() when expense != null:
return expense(_that.amount,_that.description,_that.isRecurring,_that.label);case InvestmentChange() when investment != null:
return investment(_that.principal,_that.annualReturnRate,_that.termMonths,_that.isCompound,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double principal,  double annualRate,  int termMonths,  String label)  credit,required TResult Function( double price,  double downPayment,  double annualRate,  int termMonths,  double monthlyExtras,  String label)  housing,required TResult Function( double price,  double downPayment,  double annualRate,  int termMonths,  double monthlyRunningCosts,  String label)  car,required TResult Function( double currentRent,  double newRent,  double annualIncreaseRate,  String label)  rentChange,required TResult Function( double currentGross,  double newGross,  String label)  salaryChange,required TResult Function( double amount,  String description,  bool isRecurring,  String label)  income,required TResult Function( double amount,  String description,  bool isRecurring,  String label)  expense,required TResult Function( double principal,  double annualReturnRate,  int termMonths,  bool isCompound,  String label)  investment,}) {final _that = this;
switch (_that) {
case CreditChange():
return credit(_that.principal,_that.annualRate,_that.termMonths,_that.label);case HousingChange():
return housing(_that.price,_that.downPayment,_that.annualRate,_that.termMonths,_that.monthlyExtras,_that.label);case CarChange():
return car(_that.price,_that.downPayment,_that.annualRate,_that.termMonths,_that.monthlyRunningCosts,_that.label);case RentChangeChange():
return rentChange(_that.currentRent,_that.newRent,_that.annualIncreaseRate,_that.label);case SalaryChangeChange():
return salaryChange(_that.currentGross,_that.newGross,_that.label);case IncomeChange():
return income(_that.amount,_that.description,_that.isRecurring,_that.label);case ExpenseChange():
return expense(_that.amount,_that.description,_that.isRecurring,_that.label);case InvestmentChange():
return investment(_that.principal,_that.annualReturnRate,_that.termMonths,_that.isCompound,_that.label);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double principal,  double annualRate,  int termMonths,  String label)?  credit,TResult? Function( double price,  double downPayment,  double annualRate,  int termMonths,  double monthlyExtras,  String label)?  housing,TResult? Function( double price,  double downPayment,  double annualRate,  int termMonths,  double monthlyRunningCosts,  String label)?  car,TResult? Function( double currentRent,  double newRent,  double annualIncreaseRate,  String label)?  rentChange,TResult? Function( double currentGross,  double newGross,  String label)?  salaryChange,TResult? Function( double amount,  String description,  bool isRecurring,  String label)?  income,TResult? Function( double amount,  String description,  bool isRecurring,  String label)?  expense,TResult? Function( double principal,  double annualReturnRate,  int termMonths,  bool isCompound,  String label)?  investment,}) {final _that = this;
switch (_that) {
case CreditChange() when credit != null:
return credit(_that.principal,_that.annualRate,_that.termMonths,_that.label);case HousingChange() when housing != null:
return housing(_that.price,_that.downPayment,_that.annualRate,_that.termMonths,_that.monthlyExtras,_that.label);case CarChange() when car != null:
return car(_that.price,_that.downPayment,_that.annualRate,_that.termMonths,_that.monthlyRunningCosts,_that.label);case RentChangeChange() when rentChange != null:
return rentChange(_that.currentRent,_that.newRent,_that.annualIncreaseRate,_that.label);case SalaryChangeChange() when salaryChange != null:
return salaryChange(_that.currentGross,_that.newGross,_that.label);case IncomeChange() when income != null:
return income(_that.amount,_that.description,_that.isRecurring,_that.label);case ExpenseChange() when expense != null:
return expense(_that.amount,_that.description,_that.isRecurring,_that.label);case InvestmentChange() when investment != null:
return investment(_that.principal,_that.annualReturnRate,_that.termMonths,_that.isCompound,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class CreditChange implements SimulationChange {
  const CreditChange({required this.principal, required this.annualRate, required this.termMonths, this.label = 'Kredi', final  String? $type}): $type = $type ?? 'credit';
  factory CreditChange.fromJson(Map<String, dynamic> json) => _$CreditChangeFromJson(json);

 final  double principal;
 final  double annualRate;
 final  int termMonths;
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditChangeCopyWith<CreditChange> get copyWith => _$CreditChangeCopyWithImpl<CreditChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditChange&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.annualRate, annualRate) || other.annualRate == annualRate)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,principal,annualRate,termMonths,label);

@override
String toString() {
  return 'SimulationChange.credit(principal: $principal, annualRate: $annualRate, termMonths: $termMonths, label: $label)';
}


}

/// @nodoc
abstract mixin class $CreditChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $CreditChangeCopyWith(CreditChange value, $Res Function(CreditChange) _then) = _$CreditChangeCopyWithImpl;
@override @useResult
$Res call({
 double principal, double annualRate, int termMonths, String label
});




}
/// @nodoc
class _$CreditChangeCopyWithImpl<$Res>
    implements $CreditChangeCopyWith<$Res> {
  _$CreditChangeCopyWithImpl(this._self, this._then);

  final CreditChange _self;
  final $Res Function(CreditChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? principal = null,Object? annualRate = null,Object? termMonths = null,Object? label = null,}) {
  return _then(CreditChange(
principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,annualRate: null == annualRate ? _self.annualRate : annualRate // ignore: cast_nullable_to_non_nullable
as double,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class HousingChange implements SimulationChange {
  const HousingChange({required this.price, this.downPayment = 0, required this.annualRate, required this.termMonths, this.monthlyExtras = 0, this.label = 'Ev Alımı', final  String? $type}): $type = $type ?? 'housing';
  factory HousingChange.fromJson(Map<String, dynamic> json) => _$HousingChangeFromJson(json);

 final  double price;
@JsonKey() final  double downPayment;
 final  double annualRate;
 final  int termMonths;
@JsonKey() final  double monthlyExtras;
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HousingChangeCopyWith<HousingChange> get copyWith => _$HousingChangeCopyWithImpl<HousingChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HousingChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HousingChange&&(identical(other.price, price) || other.price == price)&&(identical(other.downPayment, downPayment) || other.downPayment == downPayment)&&(identical(other.annualRate, annualRate) || other.annualRate == annualRate)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.monthlyExtras, monthlyExtras) || other.monthlyExtras == monthlyExtras)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,price,downPayment,annualRate,termMonths,monthlyExtras,label);

@override
String toString() {
  return 'SimulationChange.housing(price: $price, downPayment: $downPayment, annualRate: $annualRate, termMonths: $termMonths, monthlyExtras: $monthlyExtras, label: $label)';
}


}

/// @nodoc
abstract mixin class $HousingChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $HousingChangeCopyWith(HousingChange value, $Res Function(HousingChange) _then) = _$HousingChangeCopyWithImpl;
@override @useResult
$Res call({
 double price, double downPayment, double annualRate, int termMonths, double monthlyExtras, String label
});




}
/// @nodoc
class _$HousingChangeCopyWithImpl<$Res>
    implements $HousingChangeCopyWith<$Res> {
  _$HousingChangeCopyWithImpl(this._self, this._then);

  final HousingChange _self;
  final $Res Function(HousingChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? price = null,Object? downPayment = null,Object? annualRate = null,Object? termMonths = null,Object? monthlyExtras = null,Object? label = null,}) {
  return _then(HousingChange(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,downPayment: null == downPayment ? _self.downPayment : downPayment // ignore: cast_nullable_to_non_nullable
as double,annualRate: null == annualRate ? _self.annualRate : annualRate // ignore: cast_nullable_to_non_nullable
as double,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,monthlyExtras: null == monthlyExtras ? _self.monthlyExtras : monthlyExtras // ignore: cast_nullable_to_non_nullable
as double,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CarChange implements SimulationChange {
  const CarChange({required this.price, this.downPayment = 0, required this.annualRate, required this.termMonths, this.monthlyRunningCosts = 0, this.label = 'Araç Alımı', final  String? $type}): $type = $type ?? 'car';
  factory CarChange.fromJson(Map<String, dynamic> json) => _$CarChangeFromJson(json);

 final  double price;
@JsonKey() final  double downPayment;
 final  double annualRate;
 final  int termMonths;
@JsonKey() final  double monthlyRunningCosts;
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarChangeCopyWith<CarChange> get copyWith => _$CarChangeCopyWithImpl<CarChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarChange&&(identical(other.price, price) || other.price == price)&&(identical(other.downPayment, downPayment) || other.downPayment == downPayment)&&(identical(other.annualRate, annualRate) || other.annualRate == annualRate)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.monthlyRunningCosts, monthlyRunningCosts) || other.monthlyRunningCosts == monthlyRunningCosts)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,price,downPayment,annualRate,termMonths,monthlyRunningCosts,label);

@override
String toString() {
  return 'SimulationChange.car(price: $price, downPayment: $downPayment, annualRate: $annualRate, termMonths: $termMonths, monthlyRunningCosts: $monthlyRunningCosts, label: $label)';
}


}

/// @nodoc
abstract mixin class $CarChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $CarChangeCopyWith(CarChange value, $Res Function(CarChange) _then) = _$CarChangeCopyWithImpl;
@override @useResult
$Res call({
 double price, double downPayment, double annualRate, int termMonths, double monthlyRunningCosts, String label
});




}
/// @nodoc
class _$CarChangeCopyWithImpl<$Res>
    implements $CarChangeCopyWith<$Res> {
  _$CarChangeCopyWithImpl(this._self, this._then);

  final CarChange _self;
  final $Res Function(CarChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? price = null,Object? downPayment = null,Object? annualRate = null,Object? termMonths = null,Object? monthlyRunningCosts = null,Object? label = null,}) {
  return _then(CarChange(
price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,downPayment: null == downPayment ? _self.downPayment : downPayment // ignore: cast_nullable_to_non_nullable
as double,annualRate: null == annualRate ? _self.annualRate : annualRate // ignore: cast_nullable_to_non_nullable
as double,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,monthlyRunningCosts: null == monthlyRunningCosts ? _self.monthlyRunningCosts : monthlyRunningCosts // ignore: cast_nullable_to_non_nullable
as double,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class RentChangeChange implements SimulationChange {
  const RentChangeChange({required this.currentRent, required this.newRent, this.annualIncreaseRate = 0.0, this.label = 'Kira Değişimi', final  String? $type}): $type = $type ?? 'rentChange';
  factory RentChangeChange.fromJson(Map<String, dynamic> json) => _$RentChangeChangeFromJson(json);

 final  double currentRent;
 final  double newRent;
@JsonKey() final  double annualIncreaseRate;
// e.g. 25.0 = %25 per year
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RentChangeChangeCopyWith<RentChangeChange> get copyWith => _$RentChangeChangeCopyWithImpl<RentChangeChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RentChangeChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RentChangeChange&&(identical(other.currentRent, currentRent) || other.currentRent == currentRent)&&(identical(other.newRent, newRent) || other.newRent == newRent)&&(identical(other.annualIncreaseRate, annualIncreaseRate) || other.annualIncreaseRate == annualIncreaseRate)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentRent,newRent,annualIncreaseRate,label);

@override
String toString() {
  return 'SimulationChange.rentChange(currentRent: $currentRent, newRent: $newRent, annualIncreaseRate: $annualIncreaseRate, label: $label)';
}


}

/// @nodoc
abstract mixin class $RentChangeChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $RentChangeChangeCopyWith(RentChangeChange value, $Res Function(RentChangeChange) _then) = _$RentChangeChangeCopyWithImpl;
@override @useResult
$Res call({
 double currentRent, double newRent, double annualIncreaseRate, String label
});




}
/// @nodoc
class _$RentChangeChangeCopyWithImpl<$Res>
    implements $RentChangeChangeCopyWith<$Res> {
  _$RentChangeChangeCopyWithImpl(this._self, this._then);

  final RentChangeChange _self;
  final $Res Function(RentChangeChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentRent = null,Object? newRent = null,Object? annualIncreaseRate = null,Object? label = null,}) {
  return _then(RentChangeChange(
currentRent: null == currentRent ? _self.currentRent : currentRent // ignore: cast_nullable_to_non_nullable
as double,newRent: null == newRent ? _self.newRent : newRent // ignore: cast_nullable_to_non_nullable
as double,annualIncreaseRate: null == annualIncreaseRate ? _self.annualIncreaseRate : annualIncreaseRate // ignore: cast_nullable_to_non_nullable
as double,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SalaryChangeChange implements SimulationChange {
  const SalaryChangeChange({required this.currentGross, required this.newGross, this.label = 'Maaş Değişikliği', final  String? $type}): $type = $type ?? 'salaryChange';
  factory SalaryChangeChange.fromJson(Map<String, dynamic> json) => _$SalaryChangeChangeFromJson(json);

 final  double currentGross;
 final  double newGross;
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalaryChangeChangeCopyWith<SalaryChangeChange> get copyWith => _$SalaryChangeChangeCopyWithImpl<SalaryChangeChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalaryChangeChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalaryChangeChange&&(identical(other.currentGross, currentGross) || other.currentGross == currentGross)&&(identical(other.newGross, newGross) || other.newGross == newGross)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentGross,newGross,label);

@override
String toString() {
  return 'SimulationChange.salaryChange(currentGross: $currentGross, newGross: $newGross, label: $label)';
}


}

/// @nodoc
abstract mixin class $SalaryChangeChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $SalaryChangeChangeCopyWith(SalaryChangeChange value, $Res Function(SalaryChangeChange) _then) = _$SalaryChangeChangeCopyWithImpl;
@override @useResult
$Res call({
 double currentGross, double newGross, String label
});




}
/// @nodoc
class _$SalaryChangeChangeCopyWithImpl<$Res>
    implements $SalaryChangeChangeCopyWith<$Res> {
  _$SalaryChangeChangeCopyWithImpl(this._self, this._then);

  final SalaryChangeChange _self;
  final $Res Function(SalaryChangeChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentGross = null,Object? newGross = null,Object? label = null,}) {
  return _then(SalaryChangeChange(
currentGross: null == currentGross ? _self.currentGross : currentGross // ignore: cast_nullable_to_non_nullable
as double,newGross: null == newGross ? _self.newGross : newGross // ignore: cast_nullable_to_non_nullable
as double,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class IncomeChange implements SimulationChange {
  const IncomeChange({required this.amount, this.description = '', this.isRecurring = true, this.label = 'Gelir', final  String? $type}): $type = $type ?? 'income';
  factory IncomeChange.fromJson(Map<String, dynamic> json) => _$IncomeChangeFromJson(json);

 final  double amount;
@JsonKey() final  String description;
@JsonKey() final  bool isRecurring;
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncomeChangeCopyWith<IncomeChange> get copyWith => _$IncomeChangeCopyWithImpl<IncomeChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IncomeChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncomeChange&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,description,isRecurring,label);

@override
String toString() {
  return 'SimulationChange.income(amount: $amount, description: $description, isRecurring: $isRecurring, label: $label)';
}


}

/// @nodoc
abstract mixin class $IncomeChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $IncomeChangeCopyWith(IncomeChange value, $Res Function(IncomeChange) _then) = _$IncomeChangeCopyWithImpl;
@override @useResult
$Res call({
 double amount, String description, bool isRecurring, String label
});




}
/// @nodoc
class _$IncomeChangeCopyWithImpl<$Res>
    implements $IncomeChangeCopyWith<$Res> {
  _$IncomeChangeCopyWithImpl(this._self, this._then);

  final IncomeChange _self;
  final $Res Function(IncomeChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? description = null,Object? isRecurring = null,Object? label = null,}) {
  return _then(IncomeChange(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ExpenseChange implements SimulationChange {
  const ExpenseChange({required this.amount, this.description = '', this.isRecurring = true, this.label = 'Gider', final  String? $type}): $type = $type ?? 'expense';
  factory ExpenseChange.fromJson(Map<String, dynamic> json) => _$ExpenseChangeFromJson(json);

 final  double amount;
@JsonKey() final  String description;
@JsonKey() final  bool isRecurring;
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseChangeCopyWith<ExpenseChange> get copyWith => _$ExpenseChangeCopyWithImpl<ExpenseChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseChange&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,description,isRecurring,label);

@override
String toString() {
  return 'SimulationChange.expense(amount: $amount, description: $description, isRecurring: $isRecurring, label: $label)';
}


}

/// @nodoc
abstract mixin class $ExpenseChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $ExpenseChangeCopyWith(ExpenseChange value, $Res Function(ExpenseChange) _then) = _$ExpenseChangeCopyWithImpl;
@override @useResult
$Res call({
 double amount, String description, bool isRecurring, String label
});




}
/// @nodoc
class _$ExpenseChangeCopyWithImpl<$Res>
    implements $ExpenseChangeCopyWith<$Res> {
  _$ExpenseChangeCopyWithImpl(this._self, this._then);

  final ExpenseChange _self;
  final $Res Function(ExpenseChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? description = null,Object? isRecurring = null,Object? label = null,}) {
  return _then(ExpenseChange(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class InvestmentChange implements SimulationChange {
  const InvestmentChange({required this.principal, required this.annualReturnRate, required this.termMonths, this.isCompound = true, this.label = 'Yatırım', final  String? $type}): $type = $type ?? 'investment';
  factory InvestmentChange.fromJson(Map<String, dynamic> json) => _$InvestmentChangeFromJson(json);

 final  double principal;
 final  double annualReturnRate;
 final  int termMonths;
@JsonKey() final  bool isCompound;
@override@JsonKey() final  String label;

@JsonKey(name: 'changeType')
final String $type;


/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvestmentChangeCopyWith<InvestmentChange> get copyWith => _$InvestmentChangeCopyWithImpl<InvestmentChange>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvestmentChangeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvestmentChange&&(identical(other.principal, principal) || other.principal == principal)&&(identical(other.annualReturnRate, annualReturnRate) || other.annualReturnRate == annualReturnRate)&&(identical(other.termMonths, termMonths) || other.termMonths == termMonths)&&(identical(other.isCompound, isCompound) || other.isCompound == isCompound)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,principal,annualReturnRate,termMonths,isCompound,label);

@override
String toString() {
  return 'SimulationChange.investment(principal: $principal, annualReturnRate: $annualReturnRate, termMonths: $termMonths, isCompound: $isCompound, label: $label)';
}


}

/// @nodoc
abstract mixin class $InvestmentChangeCopyWith<$Res> implements $SimulationChangeCopyWith<$Res> {
  factory $InvestmentChangeCopyWith(InvestmentChange value, $Res Function(InvestmentChange) _then) = _$InvestmentChangeCopyWithImpl;
@override @useResult
$Res call({
 double principal, double annualReturnRate, int termMonths, bool isCompound, String label
});




}
/// @nodoc
class _$InvestmentChangeCopyWithImpl<$Res>
    implements $InvestmentChangeCopyWith<$Res> {
  _$InvestmentChangeCopyWithImpl(this._self, this._then);

  final InvestmentChange _self;
  final $Res Function(InvestmentChange) _then;

/// Create a copy of SimulationChange
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? principal = null,Object? annualReturnRate = null,Object? termMonths = null,Object? isCompound = null,Object? label = null,}) {
  return _then(InvestmentChange(
principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as double,annualReturnRate: null == annualReturnRate ? _self.annualReturnRate : annualReturnRate // ignore: cast_nullable_to_non_nullable
as double,termMonths: null == termMonths ? _self.termMonths : termMonths // ignore: cast_nullable_to_non_nullable
as int,isCompound: null == isCompound ? _self.isCompound : isCompound // ignore: cast_nullable_to_non_nullable
as bool,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
