// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppSettingsModel _$AppSettingsModelFromJson(Map<String, dynamic> json) =>
    AppSettingsModel(
      terms: json['terms'] as String?,
      privacyPolicy: json['privacy_policy'] as String?,
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      tiktok: json['tiktok'] as String?,
      phone: json['phone'] as String?,
      forcedUpdateAndroid: json['forced_update_android'] as String?,
      forcedUpdateIos: json['forced_update_ios'] as String?,
      androidVersion: json['android_version'] as String?,
      iosVersion: json['ios_version'] as String?,
      forceClose: json['force_close'] as String?,
    );

Map<String, dynamic> _$AppSettingsModelToJson(AppSettingsModel instance) =>
    <String, dynamic>{
      'terms': instance.terms,
      'privacy_policy': instance.privacyPolicy,
      'instagram': instance.instagram,
      'twitter': instance.twitter,
      'tiktok': instance.tiktok,
      'phone': instance.phone,
      'forced_update_android': instance.forcedUpdateAndroid,
      'forced_update_ios': instance.forcedUpdateIos,
      'android_version': instance.androidVersion,
      'ios_version': instance.iosVersion,
      'force_close': instance.forceClose,
    };
