// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_vehicle_type_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateVehicleTypeRequest _$UpdateVehicleTypeRequestFromJson(
  Map<String, dynamic> json,
) => UpdateVehicleTypeRequest(
  driverId: json['driverId'] as String?,
  transportDescription: json['transportDescription'] as String?,
  licensePlate: json['licensePlate'] as String?,
  transportTypeId: json['transportTypeId'] as num?,
  color: json['color'] as String?,
);

Map<String, dynamic> _$UpdateVehicleTypeRequestToJson(
  UpdateVehicleTypeRequest instance,
) => <String, dynamic>{
  'driverId': ?instance.driverId,
  'transportDescription': ?instance.transportDescription,
  'licensePlate': ?instance.licensePlate,
  'transportTypeId': ?instance.transportTypeId,
  'color': ?instance.color,
};
