import 'package:json_annotation/json_annotation.dart';

part 'game_user_permission_model.g.dart';

@JsonSerializable()
class GameUserPermissionModel {
  @JsonKey(name: 'can_join')
  final bool? canJoin;
  @JsonKey(name: 'can_leave')
  final bool? canLeave;
  @JsonKey(name: 'can_book')
  final bool? canBook;
  @JsonKey(name: 'is_member')
  final bool? isMember;
  @JsonKey(name: 'is_creator')
  final bool? isCreator;
  // Private games: whether this user (a Diwaniya admin) can pay their team's share.
  @JsonKey(name: 'can_pay_team_share')
  final bool? canPayTeamShare;
  // Private games: host | opponent, the team this user pays for.
  @JsonKey(name: 'payer_team')
  final String? payerTeam;

  GameUserPermissionModel({
    this.canJoin,
    this.canLeave,
    this.canBook,
    this.isMember,
    this.isCreator,
    this.canPayTeamShare,
    this.payerTeam,
  });

  factory GameUserPermissionModel.fromJson(Map<String, dynamic> json) => _$GameUserPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameUserPermissionModelToJson(this);
}

