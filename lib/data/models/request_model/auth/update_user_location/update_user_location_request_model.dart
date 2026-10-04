import 'package:json_annotation/json_annotation.dart';

part 'update_user_location_request_model.g.dart';

@JsonSerializable()
class UpdateUserLocationRequestModel {
  @JsonKey(name: "Latitude")
  num? latitude;
  @JsonKey(name: "Longitude")
  num? longitude;

  UpdateUserLocationRequestModel({this.latitude, this.longitude});

  factory UpdateUserLocationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserLocationRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserLocationRequestModelToJson(this);
}
