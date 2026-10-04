// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_location_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserLocationRequestModel _$UpdateUserLocationRequestModelFromJson(
  Map<String, dynamic> json,
) => UpdateUserLocationRequestModel(
  latitude: json['Latitude'] as num?,
  longitude: json['Longitude'] as num?,
);

Map<String, dynamic> _$UpdateUserLocationRequestModelToJson(
  UpdateUserLocationRequestModel instance,
) => <String, dynamic>{
  'Latitude': instance.latitude,
  'Longitude': instance.longitude,
};
