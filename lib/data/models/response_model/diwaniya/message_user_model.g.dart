// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageUserModel _$MessageUserModelFromJson(Map<String, dynamic> json) =>
    MessageUserModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$MessageUserModelToJson(MessageUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };
