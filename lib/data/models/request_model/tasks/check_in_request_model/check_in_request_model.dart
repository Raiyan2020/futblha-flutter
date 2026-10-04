import 'package:json_annotation/json_annotation.dart';

part 'check_in_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class CheckInRequestModel {
  @JsonKey(name: "Longitude")
  num? longitude;
  @JsonKey(name: "Latitude")
  num? latitude;

  CheckInRequestModel({this.longitude, this.latitude});

  factory CheckInRequestModel.fromJson(Map<String, dynamic> json) => _$CheckInRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInRequestModelToJson(this);
}
