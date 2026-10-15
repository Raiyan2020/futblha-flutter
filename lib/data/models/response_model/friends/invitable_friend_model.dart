import 'package:json_annotation/json_annotation.dart';

part 'invitable_friend_model.g.dart';

/// A friend in `GET /games/{id}/invitable-friends`.
@JsonSerializable()
class InvitableFriendModel {
  final int? id;
  final String? name;
  final String? image;
  // can_invite | already_member | already_invited | not_eligible
  @JsonKey(name: 'invite_status')
  final String? inviteStatus;
  // Translated reason when the friend can't be invited.
  final String? reason;

  InvitableFriendModel({this.id, this.name, this.image, this.inviteStatus, this.reason});

  bool get canInvite => inviteStatus == 'can_invite';

  factory InvitableFriendModel.fromJson(Map<String, dynamic> json) =>
      _$InvitableFriendModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvitableFriendModelToJson(this);
}
