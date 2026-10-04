import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/request_model/notifications/notifications_request_model.dart';
import '../../models/response_model/notifications/notifications_response_model.dart';
import '../../models/response_model/notifications/unread_count_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<ApiResultModel<NotificationsResponseModel?>> getNotifications({NotificationsRequestModel? model});
  Future<ApiResultModel<String?>> markAllNotificationsRead();
  Future<ApiResultModel<String?>> markNotificationRead({required String id});
  Future<ApiResultModel<String?>> clearNotifications();
  Future<ApiResultModel<UnreadCountModel?>> getUnReadCount();
}
