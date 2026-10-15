// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitable_friend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitableFriendModel _$InvitableFriendModelFromJson(
  Map<String, dynamic> json,
) => InvitableFriendModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  image: json['image'] as String?,
  inviteStatus: json['invite_status'] as String?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$InvitableFriendModelToJson(
  InvitableFriendModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'image': instance.image,
  'invite_status': instance.inviteStatus,
  'reason': instance.reason,
};
