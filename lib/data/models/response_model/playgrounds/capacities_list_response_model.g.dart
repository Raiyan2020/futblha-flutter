// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capacities_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CapacitiesListResponseModel _$CapacitiesListResponseModelFromJson(
  Map<String, dynamic> json,
) => CapacitiesListResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => CapacityModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CapacitiesListResponseModelToJson(
  CapacitiesListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
