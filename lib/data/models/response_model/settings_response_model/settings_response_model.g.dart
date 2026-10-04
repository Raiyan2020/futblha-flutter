// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsResponseModel _$SettingsResponseModelFromJson(
  Map<String, dynamic> json,
) => SettingsResponseModel(
  aboutUs: json['about_us'] as String?,
  terms: json['terms'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  facebook: json['facebook'] as String?,
  twitter: json['twitter'] as String?,
  instagram: json['instagram'] as String?,
  whatsapp: json['whatsapp'] as String?,
  messenger: json['messenger'] as String?,
  privacy: json['privacy'] as String?,
  tiktok: json['tiktok'] as String?,
  walletUsagePercentage: json['wallet_usage_percentage'] as String?,
  winPoints: json['win_points'] as String?,
  drawPoints: json['draw_points'] as String?,
);

Map<String, dynamic> _$SettingsResponseModelToJson(
  SettingsResponseModel instance,
) => <String, dynamic>{
  'about_us': instance.aboutUs,
  'terms': instance.terms,
  'phone': instance.phone,
  'email': instance.email,
  'facebook': instance.facebook,
  'twitter': instance.twitter,
  'instagram': instance.instagram,
  'whatsapp': instance.whatsapp,
  'messenger': instance.messenger,
  'privacy': instance.privacy,
  'tiktok': instance.tiktok,
  'wallet_usage_percentage': instance.walletUsagePercentage,
  'win_points': instance.winPoints,
  'draw_points': instance.drawPoints,
};
