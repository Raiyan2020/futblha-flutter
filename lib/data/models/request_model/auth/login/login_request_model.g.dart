// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) =>
    LoginRequestModel(
      phone: json['phone'] as String?,
      name: json['name'] as String?,
      birthdate: json['birthdate'] as String?,
      countryCode: json['country_code'] as String?,
      email: json['email'] as String?,
      deviceToken: json['device_token'] as String?,
      deviceType: json['device_type'] as String?,
    );

Map<String, dynamic> _$LoginRequestModelToJson(LoginRequestModel instance) =>
    <String, dynamic>{
      'phone': ?instance.phone,
      'name': ?instance.name,
      'birthdate': ?instance.birthdate,
      'country_code': ?instance.countryCode,
      'email': ?instance.email,
      'device_token': ?instance.deviceToken,
      'device_type': ?instance.deviceType,
    };
