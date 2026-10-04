// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diwaniya_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiwaniyaModel _$DiwaniyaModelFromJson(Map<String, dynamic> json) =>
    DiwaniyaModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      image: json['image'] as String?,
      type: json['type'] as String?,
      description: json['description'] as String?,
      wins: json['wins'] as String?,
      losses: json['losses'] as String?,
      draws: json['draws'] as String?,
      joinRequests: (json['join_requests'] as num?)?.toInt(),
      unreadMessagesCount: (json['unread_messages_count'] as num?)?.toInt(),
      totalPoints: json['total_points'] as String?,
      rank: json['rank'] as String?,
      memberStatus: json['member_status'] as String?,
      userPermission: json['user_permission'] == null
          ? null
          : UserPermissionModel.fromJson(
              json['user_permission'] as Map<String, dynamic>,
            ),
      isMyDiwaniya: json['is_my_diwaniya'] as bool?,
      creatorName: json['creator_name'] as String?,
      upcomingGames: (json['upcoming_games'] as List<dynamic>?)
          ?.map((e) => GameModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      level_rating: json['level_rating'] as String?,
      clean_game_rating: json['clean_game_rating'] as String?,
    );

Map<String, dynamic> _$DiwaniyaModelToJson(DiwaniyaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'type': instance.type,
      'description': instance.description,
      'wins': instance.wins,
      'losses': instance.losses,
      'draws': instance.draws,
      'join_requests': instance.joinRequests,
      'unread_messages_count': instance.unreadMessagesCount,
      'total_points': instance.totalPoints,
      'rank': instance.rank,
      'member_status': instance.memberStatus,
      'user_permission': instance.userPermission,
      'is_my_diwaniya': instance.isMyDiwaniya,
      'creator_name': instance.creatorName,
      'upcoming_games': instance.upcomingGames,
      'level_rating': instance.level_rating,
      'clean_game_rating': instance.clean_game_rating,
    };
