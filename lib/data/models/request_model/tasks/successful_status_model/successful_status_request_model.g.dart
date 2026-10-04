// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'successful_status_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessfulStatusRequestModel _$SuccessfulStatusRequestModelFromJson(
  Map<String, dynamic> json,
) => SuccessfulStatusRequestModel(
  TaskId: json['TaskId'] as num?,
  MainTaskId: json['MainTaskId'] as num?,
  Notes: json['Notes'] as String?,
  SignatureForm: _fileFromJson(json['SignatureForm'] as String?),
  GallaryFiles: _fileListFromJson(json['GallaryFiles'] as List?),
  Latitude: (json['Latitude'] as num?)?.toDouble(),
  Longitude: (json['Longitude'] as num?)?.toDouble(),
  Reason: json['Reason'] as String?,
);

Map<String, dynamic> _$SuccessfulStatusRequestModelToJson(
  SuccessfulStatusRequestModel instance,
) => <String, dynamic>{
  'TaskId': ?instance.TaskId,
  'MainTaskId': ?instance.MainTaskId,
  'Notes': ?instance.Notes,
  'SignatureForm': ?_fileToJson(instance.SignatureForm),
  'GallaryFiles': ?_fileListToJson(instance.GallaryFiles),
  'Longitude': ?instance.Longitude,
  'Latitude': ?instance.Latitude,
  'Reason': ?instance.Reason,
};
