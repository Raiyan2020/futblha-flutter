import 'package:json_annotation/json_annotation.dart';

import '../../enums/friendship_status.dart';

part 'friendship_status_model.g.dart';

/// `GET /users/{id}/friendship`, and the result of sending / accepting /
/// rejecting a friend request.
@JsonSerializable()
class FriendshipStatusModel {
  @JsonKey(name: 'friendship_status')
  final String? friendshipStatus;
  @JsonKey(name: 'friend_request_id')
  final int? friendRequestId;

  FriendshipStatusModel({this.friendshipStatus, this.friendRequestId});

  FriendshipStatus? get status => FriendshipStatus.fromApi(friendshipStatus);

  factory FriendshipStatusModel.fromJson(Map<String, dynamic> json) =>
      _$FriendshipStatusModelFromJson(json);

  /// `POST /friend-requests`, `/accept`, `/reject` answer with
  /// `{ "id": 15, "status": "request_sent" }`.
  factory FriendshipStatusModel.fromActionJson(Map<String, dynamic> json) => FriendshipStatusModel(
    friendshipStatus: json['status'] as String?,
    friendRequestId: (json['id'] as num?)?.toInt(),
  );

  Map<String, dynamic> toJson() => _$FriendshipStatusModelToJson(this);
}
