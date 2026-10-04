// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_invitations_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameInvitationsResponseModel _$GameInvitationsResponseModelFromJson(
  Map<String, dynamic> json,
) => GameInvitationsResponseModel(
  receivingGames: (json['receiving_games'] as List<dynamic>?)
      ?.map((e) => GameModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  sendingGames: (json['sending_games'] as List<dynamic>?)
      ?.map((e) => GameModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GameInvitationsResponseModelToJson(
  GameInvitationsResponseModel instance,
) => <String, dynamic>{
  'receiving_games': instance.receivingGames,
  'sending_games': instance.sendingGames,
};
