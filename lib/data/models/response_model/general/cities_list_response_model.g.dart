// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cities_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CitiesListResponseModel _$CitiesListResponseModelFromJson(
  Map<String, dynamic> json,
) => CitiesListResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => CityModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CitiesListResponseModelToJson(
  CitiesListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
