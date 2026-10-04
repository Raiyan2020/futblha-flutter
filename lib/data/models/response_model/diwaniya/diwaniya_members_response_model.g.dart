// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diwaniya_members_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiwaniyaMembersResponseModel _$DiwaniyaMembersResponseModelFromJson(
  Map<String, dynamic> json,
) => DiwaniyaMembersResponseModel(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => DiwaniyaMemberModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paginate: json['paginate'] == null
      ? null
      : PaginateModel.fromJson(json['paginate'] as Map<String, dynamic>),
  extra: json['extra'],
);

Map<String, dynamic> _$DiwaniyaMembersResponseModelToJson(
  DiwaniyaMembersResponseModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'paginate': instance.paginate,
  'extra': instance.extra,
};
