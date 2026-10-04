import 'package:json_annotation/json_annotation.dart';

import '../../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../../application/core/utils/mapper/data_mapper.dart';
import '../../../../domain/entities/login_entity.dart';
import '../../../../domain/entities/profile_entity.dart';

part 'profile_response_model.g.dart';

@JsonSerializable()
class ProfileResponseModel extends DataMapper<LoginEntity> {
  num? id;
  num? latitude;
  num? longitude;
  String? imageUrl;
  dynamic tags;
  String? transportDescription;
  String? licensePlate;
  String? color;
  dynamic roleNames;
  num? teamId;
  String? teamName;
  num? agentTypeId;
  String? agentTypeName;
  String? agentStatusUpdateDate;
  num? transportTypeId;
  String? transportTypeName;
  num? countryId;
  String? cid;
  String? countryName;
  String? countryCode;
  String? userId;
  String? username;
  String? email;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  String? fullName;
  num? agentStatusId;
  dynamic reason;
  String? deviceType;
  dynamic version;
  num? maxOrdersWeightsCapacity;
  num? minOrdersNoWait;
  num? assignedTasksCount;
  num? numberOfOpenTasks;
  dynamic driverCapacity;
  dynamic tokenExpirationDate;
  num? userRegistrationStatus;
  dynamic driverAvgRate;
  String? agentStatusName;
  dynamic reachedTime;
  bool? isReached;
  dynamic routeDistanceToTask;
  String? locationAccuracyName;
  num? locationAccuracyDuration;
  dynamic branchId;
  bool? isInClubbingTime;
  dynamic clubbingTimeExpiration;
  String? tokenTimeExpiration;
  bool? allPickupGeoFences;
  bool? allDeliveryGeoFences;
  String? tenant_Id;
  dynamic driverRegistrationId;
  String? driverCode;
  List<DriverPickUpGeoFencesBean>? driverPickUpGeoFences;
  List<DriverDeliveryGeoFencesBean>? driverDeliveryGeoFences;

  ProfileResponseModel(
      {this.id,
      this.latitude,
      this.longitude,
      this.imageUrl,
      this.tags,
      this.transportDescription,
      this.licensePlate,
      this.color,
      this.roleNames,
      this.teamId,
      this.teamName,
      this.agentTypeId,
      this.agentTypeName,
      this.agentStatusUpdateDate,
      this.transportTypeId,
      this.transportTypeName,
      this.countryId,
      this.cid,
      this.countryName,
      this.countryCode,
      this.userId,
      this.username,
      this.email,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.fullName,
      this.agentStatusId,
      this.reason,
      this.deviceType,
      this.version,
      this.maxOrdersWeightsCapacity,
      this.minOrdersNoWait,
      this.assignedTasksCount,
      this.numberOfOpenTasks,
      this.driverCapacity,
      this.tokenExpirationDate,
      this.userRegistrationStatus,
      this.driverAvgRate,
      this.agentStatusName,
      this.reachedTime,
      this.isReached,
      this.routeDistanceToTask,
      this.locationAccuracyName,
      this.locationAccuracyDuration,
      this.branchId,
      this.isInClubbingTime,
      this.clubbingTimeExpiration,
      this.tokenTimeExpiration,
      this.allPickupGeoFences,
      this.allDeliveryGeoFences,
      this.tenant_Id,
      this.driverRegistrationId,
      this.driverCode,
      this.driverPickUpGeoFences,
      this.driverDeliveryGeoFences});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) => _$ProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);

  @override
  LoginEntity mapToEntity() {
    return LoginEntity(
      userId: userId,
      expiredOn: tokenExpirationDate,
      message: null,
      isSuccess: true,
      token: CacheManager.instance.getAuthToken(),
      profile: ProfileEntity(
        id: userId,
        fullName: fullName,
        email: email,
        mobile: phoneNumber,
        profilePictureURL: imageUrl,
        gender: null,
        dateOfBirth: null,
        transportTypeId: transportTypeId,
        transportTypeName: transportTypeName,
        transportDescription: transportDescription,
        licensePlate: licensePlate,
        color: color,
          agentStatusId:agentStatusId,
      ),
    );
  }
}

@JsonSerializable()
class DriverDeliveryGeoFencesBean {
  num? id;
  num? driverId;
  num? geoFenceId;
  String? geoFenceName;

  DriverDeliveryGeoFencesBean({this.id, this.driverId, this.geoFenceId, this.geoFenceName});

  factory DriverDeliveryGeoFencesBean.fromJson(Map<String, dynamic> json) =>
      _$DriverDeliveryGeoFencesBeanFromJson(json);

  Map<String, dynamic> toJson() => _$DriverDeliveryGeoFencesBeanToJson(this);
}

@JsonSerializable()
class DriverPickUpGeoFencesBean {
  num? id;
  num? driverId;
  num? geoFenceId;
  String? geoFenceName;

  DriverPickUpGeoFencesBean({this.id, this.driverId, this.geoFenceId, this.geoFenceName});

  factory DriverPickUpGeoFencesBean.fromJson(Map<String, dynamic> json) => _$DriverPickUpGeoFencesBeanFromJson(json);

  Map<String, dynamic> toJson() => _$DriverPickUpGeoFencesBeanToJson(this);
}
