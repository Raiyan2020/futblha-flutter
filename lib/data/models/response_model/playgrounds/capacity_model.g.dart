// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capacity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CapacityModel _$CapacityModelFromJson(Map<String, dynamic> json) =>
    CapacityModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$CapacityModelToJson(CapacityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
    };
