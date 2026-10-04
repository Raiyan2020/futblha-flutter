// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_history_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameHistoryResponseModel _$GameHistoryResponseModelFromJson(
  Map<String, dynamic> json,
) => GameHistoryResponseModel(
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => GameModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  paginate: json['paginate'] == null
      ? null
      : PaginateModel.fromJson(json['paginate'] as Map<String, dynamic>),
  extra: json['extra'],
);

Map<String, dynamic> _$GameHistoryResponseModelToJson(
  GameHistoryResponseModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'paginate': instance.paginate,
  'extra': instance.extra,
};
