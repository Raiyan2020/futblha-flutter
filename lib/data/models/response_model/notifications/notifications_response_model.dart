import 'package:json_annotation/json_annotation.dart';
import 'package:futblha/data/models/response_model/notifications/pagination_model.dart';

part 'notifications_response_model.g.dart';

@JsonSerializable()
class NotificationsResponseModel {
  @JsonKey(name: 'data', defaultValue: [])
  final List<NotificationModel> data;
  final PaginationModel? pagination;

  NotificationsResponseModel({
    List<NotificationModel>? data,
    this.pagination,
  }) : data = data ?? [];

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsResponseModelToJson(this);
}

@JsonSerializable()
class NotificationModel {
  // The backend sends UUID strings; older rows may still be numeric.
  @JsonKey(fromJson: _idFromJson)
  final String? id;
  @JsonKey(name: 'user_id')
  final num? userId;
  @JsonKey(name: 'order_id')
  final num? orderId;
  final String? type;
  final String? title;
  final String? body;
  final String? data; // This is a JSON string
  @JsonKey(name: 'is_read')
  num? isRead;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  NotificationModel({
    this.id,
    this.userId,
    this.orderId,
    this.type,
    this.title,
    this.body,
    this.data,
    this.isRead,
    this.createdAt,
  });

  bool get isUnread => isRead != 1;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

String? _idFromJson(dynamic value) => value?.toString();
