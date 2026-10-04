import 'package:json_annotation/json_annotation.dart';

part 'notifications_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class NotificationsRequestModel {
  num? pageNumber;
  num? pageSize;
  String? searchBy;
  num? id;
  num? totalNumbers;
  String? userID;
  String? timeZone;
  String? startDate;
  String? endDate;
  String? fromDate;
  String? toDate;
  List<num>? taskStatusIds;
  num? driverId;

  NotificationsRequestModel({this.pageNumber, this.pageSize, this.searchBy, this.id, this.totalNumbers, this.userID, this.timeZone, this.startDate, this.endDate, this.fromDate, this.toDate, this.taskStatusIds, this.driverId});

  factory NotificationsRequestModel.fromJson(Map<String, dynamic> json) => _$NotificationsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsRequestModelToJson(this);
}

