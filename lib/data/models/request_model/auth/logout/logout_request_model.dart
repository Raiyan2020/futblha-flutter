import 'package:json_annotation/json_annotation.dart';

part 'logout_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class LogoutRequestModel {
  String? userId;
  num? Longitude;
  num? Latitude;
  String? deviceId;

  LogoutRequestModel({this.userId, this.Longitude, this.Latitude, this.deviceId});

  factory LogoutRequestModel.fromJson(Map<String, dynamic> json) => _$LogoutRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LogoutRequestModelToJson(this);
}

