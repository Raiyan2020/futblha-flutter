// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactResponseModel _$ContactResponseModelFromJson(
  Map<String, dynamic> json,
) => ContactResponseModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  message: json['message'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  updatedAt: json['updated_at'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ContactResponseModelToJson(
  ContactResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'message': instance.message,
  'user_id': instance.userId,
  'updated_at': instance.updatedAt,
  'created_at': instance.createdAt,
};
