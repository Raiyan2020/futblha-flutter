// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_task_status_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeTaskStatusRequest _$ChangeTaskStatusRequestFromJson(
  Map<String, dynamic> json,
) => ChangeTaskStatusRequest(
  taskId: json['taskId'] as num?,
  id: json['id'] as num?,
  longitude: json['longitude'] as num?,
  latitude: json['latitude'] as num?,
);

Map<String, dynamic> _$ChangeTaskStatusRequestToJson(
  ChangeTaskStatusRequest instance,
) => <String, dynamic>{
  'taskId': ?instance.taskId,
  'id': ?instance.id,
  'longitude': ?instance.longitude,
  'latitude': ?instance.latitude,
};
