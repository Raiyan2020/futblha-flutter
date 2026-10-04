// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facilities_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FacilitiesListResponseModel _$FacilitiesListResponseModelFromJson(
  Map<String, dynamic> json,
) => FacilitiesListResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => FacilityModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FacilitiesListResponseModelToJson(
  FacilitiesListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
