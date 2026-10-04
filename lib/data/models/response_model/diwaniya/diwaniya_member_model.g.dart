// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diwaniya_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiwaniyaMemberModel _$DiwaniyaMemberModelFromJson(Map<String, dynamic> json) =>
    DiwaniyaMemberModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$DiwaniyaMemberModelToJson(
  DiwaniyaMemberModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
  'role': instance.role,
};
