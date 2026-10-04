import 'package:json_annotation/json_annotation.dart';

part 'accept_new_task_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AcceptNewTaskRequestModel {
  num? id;
  num? longitude;
  num? latitude;

  AcceptNewTaskRequestModel({this.id, this.longitude, this.latitude});

  factory AcceptNewTaskRequestModel.fromJson(Map<String, dynamic> json) => _$AcceptNewTaskRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AcceptNewTaskRequestModelToJson(this);
}

