// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'positions_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PositionsListResponseModel _$PositionsListResponseModelFromJson(
  Map<String, dynamic> json,
) => PositionsListResponseModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => PositionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PositionsListResponseModelToJson(
  PositionsListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
