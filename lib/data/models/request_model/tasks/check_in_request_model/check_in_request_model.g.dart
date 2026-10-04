// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInRequestModel _$CheckInRequestModelFromJson(Map<String, dynamic> json) =>
    CheckInRequestModel(
      longitude: json['Longitude'] as num?,
      latitude: json['Latitude'] as num?,
    );

Map<String, dynamic> _$CheckInRequestModelToJson(
  CheckInRequestModel instance,
) => <String, dynamic>{
  'Longitude': ?instance.longitude,
  'Latitude': ?instance.latitude,
};
