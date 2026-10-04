// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameModel _$GameModelFromJson(Map<String, dynamic> json) => GameModel(
  id: (json['id'] as num?)?.toInt(),
  creatorName: json['creator_name'] as String?,
  type: json['type'] as String?,
  gameStatus: json['game_status'] as String?,
  gameStatusText: json['game_status_text'] as String?,
  invitationStatus: json['invitation_status'] as String?,
  creatorDiwaniya: json['creator_diwanya'] == null
      ? null
      : DiwaniyaModel.fromJson(json['creator_diwanya'] as Map<String, dynamic>),
  opponentDiwaniya: json['opponent_diwanya'] == null
      ? null
      : DiwaniyaModel.fromJson(
          json['opponent_diwanya'] as Map<String, dynamic>,
        ),
  booking: json['booking'] == null
      ? null
      : GameBookingModel.fromJson(json['booking'] as Map<String, dynamic>),
  players: (json['players'] as List<dynamic>?)
      ?.map((e) => GamePlayerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  playersJoines: (json['players_joines'] as num?)?.toInt(),
  playersTarget: json['players_target'],
  userPermission: json['user_permission'] == null
      ? null
      : GameUserPermissionModel.fromJson(
          json['user_permission'] as Map<String, dynamic>,
        ),
  result: json['result'] as String?,
  chatEnabled: json['chat_enabled'] as bool?,
  goalkeeperTeam1Close: json['goalkeeper_team_1_close'] as bool?,
  goalkeeperTeam2Close: json['goalkeeper_team_2_close'] as bool?,
  unreadMessagesCount: (json['unread_messages_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$GameModelToJson(GameModel instance) => <String, dynamic>{
  'id': instance.id,
  'creator_name': instance.creatorName,
  'type': instance.type,
  'game_status': instance.gameStatus,
  'game_status_text': instance.gameStatusText,
  'invitation_status': instance.invitationStatus,
  'creator_diwanya': instance.creatorDiwaniya,
  'opponent_diwanya': instance.opponentDiwaniya,
  'booking': instance.booking,
  'players': instance.players,
  'players_joines': instance.playersJoines,
  'players_target': instance.playersTarget,
  'user_permission': instance.userPermission,
  'result': instance.result,
  'chat_enabled': instance.chatEnabled,
  'goalkeeper_team_1_close': instance.goalkeeperTeam1Close,
  'goalkeeper_team_2_close': instance.goalkeeperTeam2Close,
  'unread_messages_count': instance.unreadMessagesCount,
};
