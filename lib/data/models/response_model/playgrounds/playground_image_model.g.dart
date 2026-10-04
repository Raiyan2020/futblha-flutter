// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playground_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaygroundImageModel _$PlaygroundImageModelFromJson(
  Map<String, dynamic> json,
) => PlaygroundImageModel(
  id: (json['id'] as num?)?.toInt(),
  url: json['url'] as String?,
);

Map<String, dynamic> _$PlaygroundImageModelToJson(
  PlaygroundImageModel instance,
) => <String, dynamic>{'id': instance.id, 'url': instance.url};
