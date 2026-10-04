import 'package:json_annotation/json_annotation.dart';

part 'pusher_result_model.g.dart';

@JsonSerializable()
class PusherResultModel {
  ChallengeResultResourceBean? challengeResultResource;

  PusherResultModel({this.challengeResultResource});

  factory PusherResultModel.fromJson(Map<String, dynamic> json) => _$PusherResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$PusherResultModelToJson(this);
}

@JsonSerializable()
class ChallengeResultResourceBean {
  num? id;
  num? is_active;
  num? admin_team_result;
  num? other_team_result;
  num? my_correct_answers;

  ChallengeResultResourceBean(
      {this.id, this.is_active, this.admin_team_result, this.other_team_result, this.my_correct_answers});

  factory ChallengeResultResourceBean.fromJson(Map<String, dynamic> json) =>
      _$ChallengeResultResourceBeanFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeResultResourceBeanToJson(this);
}
