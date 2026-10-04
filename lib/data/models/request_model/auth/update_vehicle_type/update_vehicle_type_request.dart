import 'package:json_annotation/json_annotation.dart';

part 'update_vehicle_type_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateVehicleTypeRequest {
  String? driverId;
  String? transportDescription;
  String? licensePlate;
  num? transportTypeId;
  String? color;

  UpdateVehicleTypeRequest(
      {this.driverId, this.transportDescription, this.licensePlate, this.transportTypeId, this.color});

  factory UpdateVehicleTypeRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateVehicleTypeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateVehicleTypeRequestToJson(this);
}
