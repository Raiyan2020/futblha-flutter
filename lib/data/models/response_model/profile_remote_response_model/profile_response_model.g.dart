// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponseModel _$ProfileResponseModelFromJson(
  Map<String, dynamic> json,
) => ProfileResponseModel(
  id: json['id'] as num?,
  latitude: json['latitude'] as num?,
  longitude: json['longitude'] as num?,
  imageUrl: json['imageUrl'] as String?,
  tags: json['tags'],
  transportDescription: json['transportDescription'] as String?,
  licensePlate: json['licensePlate'] as String?,
  color: json['color'] as String?,
  roleNames: json['roleNames'],
  teamId: json['teamId'] as num?,
  teamName: json['teamName'] as String?,
  agentTypeId: json['agentTypeId'] as num?,
  agentTypeName: json['agentTypeName'] as String?,
  agentStatusUpdateDate: json['agentStatusUpdateDate'] as String?,
  transportTypeId: json['transportTypeId'] as num?,
  transportTypeName: json['transportTypeName'] as String?,
  countryId: json['countryId'] as num?,
  cid: json['cid'] as String?,
  countryName: json['countryName'] as String?,
  countryCode: json['countryCode'] as String?,
  userId: json['userId'] as String?,
  username: json['username'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  fullName: json['fullName'] as String?,
  agentStatusId: json['agentStatusId'] as num?,
  reason: json['reason'],
  deviceType: json['deviceType'] as String?,
  version: json['version'],
  maxOrdersWeightsCapacity: json['maxOrdersWeightsCapacity'] as num?,
  minOrdersNoWait: json['minOrdersNoWait'] as num?,
  assignedTasksCount: json['assignedTasksCount'] as num?,
  numberOfOpenTasks: json['numberOfOpenTasks'] as num?,
  driverCapacity: json['driverCapacity'],
  tokenExpirationDate: json['tokenExpirationDate'],
  userRegistrationStatus: json['userRegistrationStatus'] as num?,
  driverAvgRate: json['driverAvgRate'],
  agentStatusName: json['agentStatusName'] as String?,
  reachedTime: json['reachedTime'],
  isReached: json['isReached'] as bool?,
  routeDistanceToTask: json['routeDistanceToTask'],
  locationAccuracyName: json['locationAccuracyName'] as String?,
  locationAccuracyDuration: json['locationAccuracyDuration'] as num?,
  branchId: json['branchId'],
  isInClubbingTime: json['isInClubbingTime'] as bool?,
  clubbingTimeExpiration: json['clubbingTimeExpiration'],
  tokenTimeExpiration: json['tokenTimeExpiration'] as String?,
  allPickupGeoFences: json['allPickupGeoFences'] as bool?,
  allDeliveryGeoFences: json['allDeliveryGeoFences'] as bool?,
  tenant_Id: json['tenant_Id'] as String?,
  driverRegistrationId: json['driverRegistrationId'],
  driverCode: json['driverCode'] as String?,
  driverPickUpGeoFences: (json['driverPickUpGeoFences'] as List<dynamic>?)
      ?.map(
        (e) => DriverPickUpGeoFencesBean.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  driverDeliveryGeoFences: (json['driverDeliveryGeoFences'] as List<dynamic>?)
      ?.map(
        (e) => DriverDeliveryGeoFencesBean.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$ProfileResponseModelToJson(
  ProfileResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'imageUrl': instance.imageUrl,
  'tags': instance.tags,
  'transportDescription': instance.transportDescription,
  'licensePlate': instance.licensePlate,
  'color': instance.color,
  'roleNames': instance.roleNames,
  'teamId': instance.teamId,
  'teamName': instance.teamName,
  'agentTypeId': instance.agentTypeId,
  'agentTypeName': instance.agentTypeName,
  'agentStatusUpdateDate': instance.agentStatusUpdateDate,
  'transportTypeId': instance.transportTypeId,
  'transportTypeName': instance.transportTypeName,
  'countryId': instance.countryId,
  'cid': instance.cid,
  'countryName': instance.countryName,
  'countryCode': instance.countryCode,
  'userId': instance.userId,
  'username': instance.username,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'fullName': instance.fullName,
  'agentStatusId': instance.agentStatusId,
  'reason': instance.reason,
  'deviceType': instance.deviceType,
  'version': instance.version,
  'maxOrdersWeightsCapacity': instance.maxOrdersWeightsCapacity,
  'minOrdersNoWait': instance.minOrdersNoWait,
  'assignedTasksCount': instance.assignedTasksCount,
  'numberOfOpenTasks': instance.numberOfOpenTasks,
  'driverCapacity': instance.driverCapacity,
  'tokenExpirationDate': instance.tokenExpirationDate,
  'userRegistrationStatus': instance.userRegistrationStatus,
  'driverAvgRate': instance.driverAvgRate,
  'agentStatusName': instance.agentStatusName,
  'reachedTime': instance.reachedTime,
  'isReached': instance.isReached,
  'routeDistanceToTask': instance.routeDistanceToTask,
  'locationAccuracyName': instance.locationAccuracyName,
  'locationAccuracyDuration': instance.locationAccuracyDuration,
  'branchId': instance.branchId,
  'isInClubbingTime': instance.isInClubbingTime,
  'clubbingTimeExpiration': instance.clubbingTimeExpiration,
  'tokenTimeExpiration': instance.tokenTimeExpiration,
  'allPickupGeoFences': instance.allPickupGeoFences,
  'allDeliveryGeoFences': instance.allDeliveryGeoFences,
  'tenant_Id': instance.tenant_Id,
  'driverRegistrationId': instance.driverRegistrationId,
  'driverCode': instance.driverCode,
  'driverPickUpGeoFences': instance.driverPickUpGeoFences,
  'driverDeliveryGeoFences': instance.driverDeliveryGeoFences,
};

DriverDeliveryGeoFencesBean _$DriverDeliveryGeoFencesBeanFromJson(
  Map<String, dynamic> json,
) => DriverDeliveryGeoFencesBean(
  id: json['id'] as num?,
  driverId: json['driverId'] as num?,
  geoFenceId: json['geoFenceId'] as num?,
  geoFenceName: json['geoFenceName'] as String?,
);

Map<String, dynamic> _$DriverDeliveryGeoFencesBeanToJson(
  DriverDeliveryGeoFencesBean instance,
) => <String, dynamic>{
  'id': instance.id,
  'driverId': instance.driverId,
  'geoFenceId': instance.geoFenceId,
  'geoFenceName': instance.geoFenceName,
};

DriverPickUpGeoFencesBean _$DriverPickUpGeoFencesBeanFromJson(
  Map<String, dynamic> json,
) => DriverPickUpGeoFencesBean(
  id: json['id'] as num?,
  driverId: json['driverId'] as num?,
  geoFenceId: json['geoFenceId'] as num?,
  geoFenceName: json['geoFenceName'] as String?,
);

Map<String, dynamic> _$DriverPickUpGeoFencesBeanToJson(
  DriverPickUpGeoFencesBean instance,
) => <String, dynamic>{
  'id': instance.id,
  'driverId': instance.driverId,
  'geoFenceId': instance.geoFenceId,
  'geoFenceName': instance.geoFenceName,
};
