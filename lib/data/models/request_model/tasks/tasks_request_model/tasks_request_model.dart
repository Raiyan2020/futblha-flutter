import 'package:json_annotation/json_annotation.dart';

part 'tasks_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class TasksRequestModel {
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
  String? sorting;
  num? driverId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool history;

  TasksRequestModel(
      {this.pageNumber,
      this.pageSize,
      this.searchBy,
      this.id,
      this.totalNumbers,
      this.userID,
      this.timeZone,
      this.startDate,
      this.endDate,
      this.fromDate,
      this.toDate,
      this.taskStatusIds,
      this.sorting,
      this.history = false,
      this.driverId});

  factory TasksRequestModel.fromJson(Map<String, dynamic> json) => _$TasksRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TasksRequestModelToJson(this);
}
