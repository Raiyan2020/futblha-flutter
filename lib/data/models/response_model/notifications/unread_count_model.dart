import 'package:json_annotation/json_annotation.dart';

part 'unread_count_model.g.dart';

@JsonSerializable()
class UnreadCountModel {
  @JsonKey(name: 'unread_count', defaultValue: 0)
  final int unreadCount;
  @JsonKey(name: 'pending_invitations_count', defaultValue: 0)
  final int pendingInvitationsCount;

  UnreadCountModel({this.unreadCount = 0, this.pendingInvitationsCount = 0});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) => _$UnreadCountModelFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountModelToJson(this);
}
