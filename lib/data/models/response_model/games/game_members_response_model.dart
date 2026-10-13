import 'package:json_annotation/json_annotation.dart';
import 'game_player_model.dart';

part 'game_members_response_model.g.dart';

@JsonSerializable()
class GameMembersResponseModel {
  @JsonKey(name: 'my_team')
  final List<GamePlayerModel>? myTeam;
  @JsonKey(name: 'opposing_team')
  final List<GamePlayerModel>? opposingTeam;
  @JsonKey(name: 'team_1')
  final List<GamePlayerModel>? team1;
  @JsonKey(name: 'team_2')
  final List<GamePlayerModel>? team2;

  GameMembersResponseModel({
    this.myTeam,
    this.opposingTeam,
    this.team1,
    this.team2,
  });

  factory GameMembersResponseModel.fromJson(Map<String, dynamic> json) => _$GameMembersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameMembersResponseModelToJson(this);

  // Getter to get myTeam or team1 (for members vs non-members)
  List<GamePlayerModel> get myTeamPlayers => myTeam ?? team1 ?? [];

  // Getter to get opposingTeam or team2 (for members vs non-members)
  List<GamePlayerModel> get opposingTeamPlayers => opposingTeam ?? team2 ?? [];

  // /members is relative to the viewer and /players is absolute, so the pitch splits
  // players by their own `team` field to keep team_1 on top for everyone. A player
  // without `team` stays on the side of the list it came from.
  List<GamePlayerModel> get topTeamPlayers => [
    ...myTeamPlayers.where((p) => p.team != 'team_2'),
    ...opposingTeamPlayers.where((p) => p.team == 'team_1'),
  ];

  List<GamePlayerModel> get bottomTeamPlayers => [
    ...opposingTeamPlayers.where((p) => p.team != 'team_1'),
    ...myTeamPlayers.where((p) => p.team == 'team_2'),
  ];
}

