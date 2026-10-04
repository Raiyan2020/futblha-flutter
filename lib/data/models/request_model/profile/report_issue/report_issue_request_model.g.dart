// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_issue_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportIssueRequestModel _$ReportIssueRequestModelFromJson(
  Map<String, dynamic> json,
) => ReportIssueRequestModel(
  userId: json['userId'] as String?,
  subject: json['subject'] as String?,
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$ReportIssueRequestModelToJson(
  ReportIssueRequestModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'subject': instance.subject,
  'comment': instance.comment,
};
