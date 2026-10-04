import 'package:futblha/data/models/enums/vehicle_type.dart';
import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  const ProfileEntity({
    this.id,
    this.fullName,
    this.civilId,
    this.email,
    this.mobile,
    this.profilePictureURL,
    this.gender,
    this.dateOfBirth,
    this.transportTypeId,
    this.transportTypeName,
    this.transportDescription,
    this.licensePlate,
    this.color,
    this.agentStatusId,
  });

  final String? id;
  final String? fullName;
  final String? civilId;
  final String? email;
  final String? mobile;
  final String? profilePictureURL;
  final int? gender;
  final String? dateOfBirth;
  final num? transportTypeId;
  final String? transportTypeName;
  final String? transportDescription;
  final String? licensePlate;
  final String? color;
  final num? agentStatusId;
  VehicleType get vehicleType => VehicleType.getTypeFromInt(transportTypeId!.toInt());

  @override
  List<Object?> get props => <Object?>[id, fullName, civilId, email, mobile, gender, dateOfBirth];
}
