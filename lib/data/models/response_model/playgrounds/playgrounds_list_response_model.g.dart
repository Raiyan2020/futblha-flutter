// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playgrounds_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaygroundsListResponseModel _$PlaygroundsListResponseModelFromJson(
  Map<String, dynamic> json,
) => PlaygroundsListResponseModel(
  items: (json['items'] as List<dynamic>)
      .map((e) => PlaygroundModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paginate: PaginationModel.fromJson(json['paginate'] as Map<String, dynamic>),
  extra: json['extra'],
);

Map<String, dynamic> _$PlaygroundsListResponseModelToJson(
  PlaygroundsListResponseModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'paginate': instance.paginate,
  'extra': instance.extra,
};
