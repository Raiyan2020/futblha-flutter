import 'package:json_annotation/json_annotation.dart';

part 'user_permission_model.g.dart';

@JsonSerializable()
class UserPermissionModel {
  @JsonKey(name: 'is_admin')
  final bool? isAdmin;
  @JsonKey(name: 'is_member')
  final bool? isMember;
  @JsonKey(name: 'can_join')
  final bool? canJoin;
  @JsonKey(name: 'can_leave')
  final bool? canLeave;

  UserPermissionModel({
    this.isAdmin,
    this.isMember,
    this.canJoin,
    this.canLeave,
  });

  factory UserPermissionModel.fromJson(Map<String, dynamic> json) => _$UserPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserPermissionModelToJson(this);
}

