// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagesResponseModel _$MessagesResponseModelFromJson(
  Map<String, dynamic> json,
) => MessagesResponseModel(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paginate: json['paginate'] == null
      ? null
      : PaginateModel.fromJson(json['paginate'] as Map<String, dynamic>),
  extra: json['extra'],
);

Map<String, dynamic> _$MessagesResponseModelToJson(
  MessagesResponseModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'paginate': instance.paginate,
  'extra': instance.extra,
};
