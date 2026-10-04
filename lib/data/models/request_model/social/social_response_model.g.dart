// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialResponseModel _$SocialResponseModelFromJson(Map<String, dynamic> json) =>
    SocialResponseModel(
      twitter: json['twitter'] as String?,
      tiktok: json['tiktok'] as String?,
      snapchat: json['snapchat'] as String?,
      instagram: json['instagram'] as String?,
    );

Map<String, dynamic> _$SocialResponseModelToJson(
  SocialResponseModel instance,
) => <String, dynamic>{
  'twitter': instance.twitter,
  'tiktok': instance.tiktok,
  'snapchat': instance.snapchat,
  'instagram': instance.instagram,
};
