import 'package:json_annotation/json_annotation.dart';
import 'game_model.dart';

part 'game_invitations_response_model.g.dart';

@JsonSerializable()
class GameInvitationsResponseModel {
  @JsonKey(name: 'receiving_games')
  final List<GameModel>? receivingGames;
  @JsonKey(name: 'sending_games')
  final List<GameModel>? sendingGames;

  GameInvitationsResponseModel({
    this.receivingGames,
    this.sendingGames,
  });

  factory GameInvitationsResponseModel.fromJson(Map<String, dynamic> json) => _$GameInvitationsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameInvitationsResponseModelToJson(this);
}

