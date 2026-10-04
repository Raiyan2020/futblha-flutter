// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPermissionModel _$UserPermissionModelFromJson(Map<String, dynamic> json) =>
    UserPermissionModel(
      isAdmin: json['is_admin'] as bool?,
      isMember: json['is_member'] as bool?,
      canJoin: json['can_join'] as bool?,
      canLeave: json['can_leave'] as bool?,
    );

Map<String, dynamic> _$UserPermissionModelToJson(
  UserPermissionModel instance,
) => <String, dynamic>{
  'is_admin': instance.isAdmin,
  'is_member': instance.isMember,
  'can_join': instance.canJoin,
  'can_leave': instance.canLeave,
};
