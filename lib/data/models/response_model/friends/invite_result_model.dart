import 'package:json_annotation/json_annotation.dart';

part 'invite_result_model.g.dart';

/// Per-friend result of `POST /games/{id}/invite-friends`.
@JsonSerializable()
class InviteResultModel {
  @JsonKey(name: 'user_id')
  final int? userId;
  // invited | already_member | already_invited | not_eligible
  final String? status;
  final String? msg;

  InviteResultModel({this.userId, this.status, this.msg});

  factory InviteResultModel.fromJson(Map<String, dynamic> json) =>
      _$InviteResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$InviteResultModelToJson(this);
}
