import 'package:json_annotation/json_annotation.dart';
import '../diwaniya/diwaniya_model.dart';
import 'game_booking_model.dart';
import 'game_player_model.dart';
import 'game_user_permission_model.dart';

part 'game_model.g.dart';

@JsonSerializable()
class GameModel {
  final int? id;
  @JsonKey(name: 'creator_name')
  final String? creatorName;
  final String? type; // private, public, my_diwanya
  @JsonKey(name: 'game_status')
  final String? gameStatus;
  @JsonKey(name: 'game_status_text')
  final String? gameStatusText;
  @JsonKey(name: 'invitation_status')
  final String? invitationStatus;
  @JsonKey(name: 'creator_diwanya')
  final DiwaniyaModel? creatorDiwaniya;
  @JsonKey(name: 'opponent_diwanya')
  final DiwaniyaModel? opponentDiwaniya;
  final GameBookingModel? booking;
  final List<GamePlayerModel>? players;
  @JsonKey(name: 'players_joines')
  final int? playersJoines;
  @JsonKey(name: 'players_target')
  final dynamic playersTarget;
  @JsonKey(name: 'user_permission')
  final GameUserPermissionModel? userPermission;
  final String? result; // win, lose, draw
  @JsonKey(name: 'chat_enabled')
  final bool? chatEnabled;
  @JsonKey(name: 'goalkeeper_team_1_close')
  final bool? goalkeeperTeam1Close;
  @JsonKey(name: 'goalkeeper_team_2_close')
  final bool? goalkeeperTeam2Close;
  @JsonKey(name: 'unread_messages_count')
  int? unreadMessagesCount;


  GameModel({
    this.id,
    this.creatorName,
    this.type,
    this.gameStatus,
    this.gameStatusText,
    this.invitationStatus,
    this.creatorDiwaniya,
    this.opponentDiwaniya,
    this.booking,
    this.players,
    this.playersJoines,
    this.playersTarget,
    this.userPermission,
    this.result,
    this.chatEnabled,
    this.goalkeeperTeam1Close,
    this.goalkeeperTeam2Close,
    this.unreadMessagesCount,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) => _$GameModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameModelToJson(this);
}
