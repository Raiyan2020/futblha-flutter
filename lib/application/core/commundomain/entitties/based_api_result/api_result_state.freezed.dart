// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_result_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiResultState<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResultState<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiResultState<$T>()';
}


}

/// @nodoc
class $ApiResultStateCopyWith<T,$Res>  {
$ApiResultStateCopyWith(ApiResultState<T> _, $Res Function(ApiResultState<T>) __);
}


/// Adds pattern-matching-related methods to [ApiResultState].
extension ApiResultStatePatterns<T> on ApiResultState<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Data<T> value)?  data,TResult Function( Error<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Data() when data != null:
return data(_that);case Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Data<T> value)  data,required TResult Function( Error<T> value)  error,}){
final _that = this;
switch (_that) {
case Data():
return data(_that);case Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Data<T> value)?  data,TResult? Function( Error<T> value)?  error,}){
final _that = this;
switch (_that) {
case Data() when data != null:
return data(_that);case Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T data)?  data,TResult Function( ErrorResultModel errorResultModel)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Data() when data != null:
return data(_that.data);case Error() when error != null:
return error(_that.errorResultModel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T data)  data,required TResult Function( ErrorResultModel errorResultModel)  error,}) {final _that = this;
switch (_that) {
case Data():
return data(_that.data);case Error():
return error(_that.errorResultModel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T data)?  data,TResult? Function( ErrorResultModel errorResultModel)?  error,}) {final _that = this;
switch (_that) {
case Data() when data != null:
return data(_that.data);case Error() when error != null:
return error(_that.errorResultModel);case _:
  return null;

}
}

}

/// @nodoc


class Data<T> implements ApiResultState<T> {
  const Data({required this.data});
  

 final  T data;

/// Create a copy of ApiResultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataCopyWith<T, Data<T>> get copyWith => _$DataCopyWithImpl<T, Data<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Data<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'ApiResultState<$T>.data(data: $data)';
}


}

/// @nodoc
abstract mixin class $DataCopyWith<T,$Res> implements $ApiResultStateCopyWith<T, $Res> {
  factory $DataCopyWith(Data<T> value, $Res Function(Data<T>) _then) = _$DataCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$DataCopyWithImpl<T,$Res>
    implements $DataCopyWith<T, $Res> {
  _$DataCopyWithImpl(this._self, this._then);

  final Data<T> _self;
  final $Res Function(Data<T>) _then;

/// Create a copy of ApiResultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Data<T>(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class Error<T> implements ApiResultState<T> {
  const Error({required this.errorResultModel});
  

 final  ErrorResultModel errorResultModel;

/// Create a copy of ApiResultState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorCopyWith<T, Error<T>> get copyWith => _$ErrorCopyWithImpl<T, Error<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Error<T>&&(identical(other.errorResultModel, errorResultModel) || other.errorResultModel == errorResultModel));
}


@override
int get hashCode => Object.hash(runtimeType,errorResultModel);

@override
String toString() {
  return 'ApiResultState<$T>.error(errorResultModel: $errorResultModel)';
}


}

/// @nodoc
abstract mixin class $ErrorCopyWith<T,$Res> implements $ApiResultStateCopyWith<T, $Res> {
  factory $ErrorCopyWith(Error<T> value, $Res Function(Error<T>) _then) = _$ErrorCopyWithImpl;
@useResult
$Res call({
 ErrorResultModel errorResultModel
});




}
/// @nodoc
class _$ErrorCopyWithImpl<T,$Res>
    implements $ErrorCopyWith<T, $Res> {
  _$ErrorCopyWithImpl(this._self, this._then);

  final Error<T> _self;
  final $Res Function(Error<T>) _then;

/// Create a copy of ApiResultState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorResultModel = null,}) {
  return _then(Error<T>(
errorResultModel: null == errorResultModel ? _self.errorResultModel : errorResultModel // ignore: cast_nullable_to_non_nullable
as ErrorResultModel,
  ));
}


}

// dart format on
