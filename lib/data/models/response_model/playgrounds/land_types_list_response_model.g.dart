// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'land_types_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LandTypesListResponseModel _$LandTypesListResponseModelFromJson(
  Map<String, dynamic> json,
) => LandTypesListResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => LandTypeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LandTypesListResponseModelToJson(
  LandTypesListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
