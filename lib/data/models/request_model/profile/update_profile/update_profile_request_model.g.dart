// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequestModel _$UpdateProfileRequestModelFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequestModel(
  phone: json['phone'] as String?,
  currentPassword: json['currentPassword'] as String?,
  newPassword: json['newPassword'] as String?,
  confirmPassword: json['confirmPassword'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestModelToJson(
  UpdateProfileRequestModel instance,
) => <String, dynamic>{
  'phone': ?instance.phone,
  'currentPassword': ?instance.currentPassword,
  'newPassword': ?instance.newPassword,
  'confirmPassword': ?instance.confirmPassword,
};
