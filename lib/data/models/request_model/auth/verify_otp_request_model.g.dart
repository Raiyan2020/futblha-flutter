// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyOtpRequestModel _$VerifyOtpRequestModelFromJson(
  Map<String, dynamic> json,
) => VerifyOtpRequestModel(
  phone: json['phone'] as String?,
  activationCode: json['activation_code'] as String?,
  countryCode: json['country_code'] as String?,
);

Map<String, dynamic> _$VerifyOtpRequestModelToJson(
  VerifyOtpRequestModel instance,
) => <String, dynamic>{
  'phone': instance.phone,
  'activation_code': instance.activationCode,
  'country_code': instance.countryCode,
};
