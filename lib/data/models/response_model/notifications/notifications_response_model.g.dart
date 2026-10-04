// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsResponseModel _$NotificationsResponseModelFromJson(
  Map<String, dynamic> json,
) => NotificationsResponseModel(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  pagination: json['pagination'] == null
      ? null
      : PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NotificationsResponseModelToJson(
  NotificationsResponseModel instance,
) => <String, dynamic>{
  'data': instance.data,
  'pagination': instance.pagination,
};

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as num?,
      userId: json['user_id'] as num?,
      orderId: json['order_id'] as num?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] as String?,
      isRead: json['is_read'] as num?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'order_id': instance.orderId,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
    };
