// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TasksRequestModel _$TasksRequestModelFromJson(Map<String, dynamic> json) =>
    TasksRequestModel(
      pageNumber: json['pageNumber'] as num?,
      pageSize: json['pageSize'] as num?,
      searchBy: json['searchBy'] as String?,
      id: json['id'] as num?,
      totalNumbers: json['totalNumbers'] as num?,
      userID: json['userID'] as String?,
      timeZone: json['timeZone'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      fromDate: json['fromDate'] as String?,
      toDate: json['toDate'] as String?,
      taskStatusIds: (json['taskStatusIds'] as List<dynamic>?)
          ?.map((e) => e as num)
          .toList(),
      sorting: json['sorting'] as String?,
      driverId: json['driverId'] as num?,
    );

Map<String, dynamic> _$TasksRequestModelToJson(TasksRequestModel instance) =>
    <String, dynamic>{
      'pageNumber': ?instance.pageNumber,
      'pageSize': ?instance.pageSize,
      'searchBy': ?instance.searchBy,
      'id': ?instance.id,
      'totalNumbers': ?instance.totalNumbers,
      'userID': ?instance.userID,
      'timeZone': ?instance.timeZone,
      'startDate': ?instance.startDate,
      'endDate': ?instance.endDate,
      'fromDate': ?instance.fromDate,
      'toDate': ?instance.toDate,
      'taskStatusIds': ?instance.taskStatusIds,
      'sorting': ?instance.sorting,
      'driverId': ?instance.driverId,
    };
