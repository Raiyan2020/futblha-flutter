// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playground_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaygroundModel _$PlaygroundModelFromJson(Map<String, dynamic> json) =>
    PlaygroundModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
      price: json['price'] as String?,
      city: json['city'] as String?,
      rate: json['rate'],
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      landType: json['land_type'] as String?,
      capacity: json['capacity'] as String?,
      description: json['description'] as String?,
      facilities: (json['facilities'] as List<dynamic>?)
          ?.map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => PlaygroundImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PlaygroundModelToJson(PlaygroundModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'price': instance.price,
      'city': instance.city,
      'rate': instance.rate,
      'lat': instance.lat,
      'lng': instance.lng,
      'land_type': instance.landType,
      'capacity': instance.capacity,
      'description': instance.description,
      'facilities': instance.facilities,
      'images': instance.images,
    };
