// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_player_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GamePlayerModel _$GamePlayerModelFromJson(Map<String, dynamic> json) =>
    GamePlayerModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
      position: json['position'] as String?,
      positionText: json['position_text'] as String?,
      slotIndex: json['slot_index'] as String?,
      teamIndex: (json['team_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GamePlayerModelToJson(GamePlayerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'position': instance.position,
      'position_text': instance.positionText,
      'slot_index': instance.slotIndex,
      'team_index': instance.teamIndex,
    };
