import 'package:json_annotation/json_annotation.dart';

part 'change_task_status_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ChangeTaskStatusRequest {
  num? taskId;
  num? id;
  num? longitude;
  num? latitude;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String url;

  ChangeTaskStatusRequest({this.url = '', this.taskId, this.id, this.longitude, this.latitude});

  factory ChangeTaskStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangeTaskStatusRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeTaskStatusRequestToJson(this);
}
