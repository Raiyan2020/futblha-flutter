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

  GameUserPermissionModel({
    this.canJoin,
    this.canLeave,
    this.canBook,
    this.isMember,
    this.isCreator,
  });

  factory GameUserPermissionModel.fromJson(Map<String, dynamic> json) => _$GameUserPermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameUserPermissionModelToJson(this);
}

