// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_settings_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserSettingsRequestModel _$UpdateUserSettingsRequestModelFromJson(
  Map<String, dynamic> json,
) => UpdateUserSettingsRequestModel(
  notificationEnabled: json['notification_enabled'] as String?,
  language: json['language'] as String?,
);

Map<String, dynamic> _$UpdateUserSettingsRequestModelToJson(
  UpdateUserSettingsRequestModel instance,
) => <String, dynamic>{
  'notification_enabled': instance.notificationEnabled,
  'language': instance.language,
};
