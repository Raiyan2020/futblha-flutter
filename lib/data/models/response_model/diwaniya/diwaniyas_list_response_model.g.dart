// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diwaniyas_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiwaniyasListResponseModel _$DiwaniyasListResponseModelFromJson(
  Map<String, dynamic> json,
) => DiwaniyasListResponseModel(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => DiwaniyaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paginate: json['paginate'] == null
      ? null
      : PaginateModel.fromJson(json['paginate'] as Map<String, dynamic>),
  extra: json['extra'],
);

Map<String, dynamic> _$DiwaniyasListResponseModelToJson(
  DiwaniyasListResponseModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'paginate': instance.paginate,
  'extra': instance.extra,
};
