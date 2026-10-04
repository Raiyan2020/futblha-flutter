// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failure_reasons_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FailureReasonsRequest _$FailureReasonsRequestFromJson(
  Map<String, dynamic> json,
) => FailureReasonsRequest(
  actionTypeId: json['actionTypeId'] as num?,
  mainTaskId: json['mainTaskId'] as num?,
);

Map<String, dynamic> _$FailureReasonsRequestToJson(
  FailureReasonsRequest instance,
) => <String, dynamic>{
  'actionTypeId': ?instance.actionTypeId,
  'mainTaskId': ?instance.mainTaskId,
};
