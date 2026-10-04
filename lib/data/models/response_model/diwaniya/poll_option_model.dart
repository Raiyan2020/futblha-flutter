import 'package:futblha/data/models/response_model/login_remote_response_model/login_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'poll_option_model.g.dart';

@JsonSerializable()
class PollOptionModel {
  final int? id;
  @JsonKey(name: 'option_text')
  final String? optionText;
  @JsonKey(name: 'votes_count')
  final int? votesCount;
  @JsonKey(name: 'voters')
  final List<UserModel>? voters;

  PollOptionModel({this.id, this.optionText, this.votesCount, this.voters});

  factory PollOptionModel.fromJson(Map<String, dynamic> json) => _$PollOptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PollOptionModelToJson(this);
}
