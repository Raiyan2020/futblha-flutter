import 'package:json_annotation/json_annotation.dart';
import 'user_permission_model.dart';
import '../games/game_model.dart';

part 'diwaniya_model.g.dart';

@JsonSerializable()
class DiwaniyaModel {
  final int? id;
  final String? name;
  final String? image;
  final String? type;
  final String? description;
  final String? wins;
  final String? losses;
  final String? draws;
  @JsonKey(name: 'join_requests')
  final int? joinRequests;
  @JsonKey(name: 'unread_messages_count')
  int? unreadMessagesCount;
  @JsonKey(name: 'total_points')
  final String? totalPoints;
  final String? rank;
  @JsonKey(name: 'member_status')
  final String? memberStatus;
  @JsonKey(name: 'user_permission')
  final UserPermissionModel? userPermission;
  @JsonKey(name: 'is_my_diwaniya')
  final bool? isMyDiwaniya;
  @JsonKey(name: 'creator_name')
  final String? creatorName;
  @JsonKey(name: 'upcoming_games')
  final List<GameModel>? upcomingGames;
  final String? level_rating;
  final String? clean_game_rating;

  DiwaniyaModel({
    this.id,
    this.name,
    this.image,
    this.type,
    this.description,
    this.wins,
    this.losses,
    this.draws,
    this.joinRequests,
    this.unreadMessagesCount,
    this.totalPoints,
    this.rank,
    this.memberStatus,
    this.userPermission,
    this.isMyDiwaniya,
    this.creatorName,
    this.upcomingGames,
    this.level_rating,
    this.clean_game_rating,
  });

  factory DiwaniyaModel.fromJson(Map<String, dynamic> json) => _$DiwaniyaModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiwaniyaModelToJson(this);
}
