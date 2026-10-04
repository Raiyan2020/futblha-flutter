// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countries_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountriesListResponseModel _$CountriesListResponseModelFromJson(
  Map<String, dynamic> json,
) => CountriesListResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CountriesListResponseModelToJson(
  CountriesListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
