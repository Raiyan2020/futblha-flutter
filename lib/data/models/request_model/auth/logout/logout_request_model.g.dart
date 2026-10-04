// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogoutRequestModel _$LogoutRequestModelFromJson(Map<String, dynamic> json) =>
    LogoutRequestModel(
      userId: json['userId'] as String?,
      Longitude: json['Longitude'] as num?,
      Latitude: json['Latitude'] as num?,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$LogoutRequestModelToJson(LogoutRequestModel instance) =>
    <String, dynamic>{
      'userId': ?instance.userId,
      'Longitude': ?instance.Longitude,
      'Latitude': ?instance.Latitude,
      'deviceId': ?instance.deviceId,
    };
