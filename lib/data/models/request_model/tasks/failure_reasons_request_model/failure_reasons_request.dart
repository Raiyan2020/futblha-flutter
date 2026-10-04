import 'package:json_annotation/json_annotation.dart';

part 'failure_reasons_request.g.dart';

@JsonSerializable(includeIfNull: false)
class FailureReasonsRequest {
  num? actionTypeId;
  num? mainTaskId;

  FailureReasonsRequest({this.actionTypeId, this.mainTaskId});

  factory FailureReasonsRequest.fromJson(Map<String, dynamic> json) => _$FailureReasonsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FailureReasonsRequestToJson(this);
}
