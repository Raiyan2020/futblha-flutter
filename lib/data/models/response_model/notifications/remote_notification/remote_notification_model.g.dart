// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteNotificationModel _$RemoteNotificationModelFromJson(
  Map<String, dynamic> json,
) => RemoteNotificationModel(
  MessageData: json['MessageData'] == null
      ? null
      : MessageDataBean.fromJson(json['MessageData'] as Map<String, dynamic>),
  NotificationType: json['NotificationType'] as String?,
  body: json['body'] as String?,
  type: json['type'] as String?,
  title: json['title'] as String?,
);

Map<String, dynamic> _$RemoteNotificationModelToJson(
  RemoteNotificationModel instance,
) => <String, dynamic>{
  'MessageData': instance.MessageData,
  'NotificationType': instance.NotificationType,
  'body': instance.body,
  'type': instance.type,
  'title': instance.title,
};

MessageDataBean _$MessageDataBeanFromJson(Map<String, dynamic> json) =>
    MessageDataBean(UserId: json['UserId'] as String?)
      ..isRequiredAcceptOrDecline = json['IsRequiredAcceptOrDecline'] as bool?
      ..isLoggedOut = json['IsLoggedOut'] as bool?
      ..expirationTime = (json['ExpirationTime'] as num?)?.toInt()
      ..notificationType = (json['NotificationType'] as num?)?.toInt()
      ..subtaskID = json['SubTaskId'] as num?
      ..mainTaskID = json['MainTaskId'] as num?;

Map<String, dynamic> _$MessageDataBeanToJson(MessageDataBean instance) =>
    <String, dynamic>{
      'UserId': instance.UserId,
      'IsRequiredAcceptOrDecline': instance.isRequiredAcceptOrDecline,
      'IsLoggedOut': instance.isLoggedOut,
      'ExpirationTime': instance.expirationTime,
      'NotificationType': instance.notificationType,
      'SubTaskId': instance.subtaskID,
      'MainTaskId': instance.mainTaskID,
    };
