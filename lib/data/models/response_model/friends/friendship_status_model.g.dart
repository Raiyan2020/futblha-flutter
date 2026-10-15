// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendshipStatusModel _$FriendshipStatusModelFromJson(
  Map<String, dynamic> json,
) => FriendshipStatusModel(
  friendshipStatus: json['friendship_status'] as String?,
  friendRequestId: (json['friend_request_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$FriendshipStatusModelToJson(
  FriendshipStatusModel instance,
) => <String, dynamic>{
  'friendship_status': instance.friendshipStatus,
  'friend_request_id': instance.friendRequestId,
};
