// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusAPI _$StatusAPIFromJson(Map<String, dynamic> json) => StatusAPI(
  code: json['code'] as num?,
  subCode: json['subCode'] as num?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$StatusAPIToJson(StatusAPI instance) => <String, dynamic>{
  'code': instance.code,
  'subCode': instance.subCode,
  'message': instance.message,
};
