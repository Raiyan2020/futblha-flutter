// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_members_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameMembersResponseModel _$GameMembersResponseModelFromJson(
  Map<String, dynamic> json,
) => GameMembersResponseModel(
  myTeam: (json['my_team'] as List<dynamic>?)
      ?.map((e) => GamePlayerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  opposingTeam: (json['opposing_team'] as List<dynamic>?)
      ?.map((e) => GamePlayerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  team1: (json['team_1'] as List<dynamic>?)
      ?.map((e) => GamePlayerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  team2: (json['team_2'] as List<dynamic>?)
      ?.map((e) => GamePlayerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GameMembersResponseModelToJson(
  GameMembersResponseModel instance,
) => <String, dynamic>{
  'my_team': instance.myTeam,
  'opposing_team': instance.opposingTeam,
  'team_1': instance.team1,
  'team_2': instance.team2,
};
