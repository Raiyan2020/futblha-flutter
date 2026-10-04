// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_user_permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameUserPermissionModel _$GameUserPermissionModelFromJson(
  Map<String, dynamic> json,
) => GameUserPermissionModel(
  canJoin: json['can_join'] as bool?,
  canLeave: json['can_leave'] as bool?,
  canBook: json['can_book'] as bool?,
  isMember: json['is_member'] as bool?,
  isCreator: json['is_creator'] as bool?,
);

Map<String, dynamic> _$GameUserPermissionModelToJson(
  GameUserPermissionModel instance,
) => <String, dynamic>{
  'can_join': instance.canJoin,
  'can_leave': instance.canLeave,
  'can_book': instance.canBook,
  'is_member': instance.isMember,
  'is_creator': instance.isCreator,
};
