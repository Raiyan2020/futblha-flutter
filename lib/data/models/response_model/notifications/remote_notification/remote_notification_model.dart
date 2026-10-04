import 'package:json_annotation/json_annotation.dart';

part 'remote_notification_model.g.dart';

@JsonSerializable()
class RemoteNotificationModel {
  MessageDataBean? MessageData;
  String? NotificationType;
  String? body;
  String? type;
  String? title;

  RemoteNotificationModel({this.MessageData, this.NotificationType, this.body, this.type, this.title});

  factory RemoteNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$RemoteNotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$RemoteNotificationModelToJson(this);
}

@JsonSerializable()
class MessageDataBean {
  String? UserId;
  @JsonKey(name: 'IsRequiredAcceptOrDecline')
  bool? isRequiredAcceptOrDecline;
  @JsonKey(name: 'IsLoggedOut')
  bool? isLoggedOut;
  @JsonKey(name: 'ExpirationTime')
  int? expirationTime;
  @JsonKey(name: 'NotificationType')
  int? notificationType;
  @JsonKey(name: 'SubTaskId')
  num? subtaskID;
  @JsonKey(name: 'MainTaskId')
  num? mainTaskID;

  MessageDataBean({this.UserId});

  factory MessageDataBean.fromJson(Map<String, dynamic> json) => _$MessageDataBeanFromJson(json);

  Map<String, dynamic> toJson() => _$MessageDataBeanToJson(this);
}
