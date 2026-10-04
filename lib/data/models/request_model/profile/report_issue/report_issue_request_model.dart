import 'package:json_annotation/json_annotation.dart';

part 'report_issue_request_model.g.dart';

@JsonSerializable()
class ReportIssueRequestModel {
  final String? userId;
  final String? subject;
  final String? comment;

  ReportIssueRequestModel({
    this.userId,
    this.subject,
    this.comment,
  });

  factory ReportIssueRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ReportIssueRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportIssueRequestModelToJson(this);
}
