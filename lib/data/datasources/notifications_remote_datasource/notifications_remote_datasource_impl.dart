import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/constants/app_constants.dart';
import '../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../models/request_model/notifications/notifications_request_model.dart';
import '../../models/response_model/notifications/notifications_response_model.dart';
import '../../models/response_model/notifications/unread_count_model.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'notifications_remote_datasource.dart';

@Injectable(as: NotificationsRemoteDataSource)
class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._apiCallHelper);

  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<NotificationsResponseModel?>> getNotifications({
    NotificationsRequestModel? model,
  }) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: GetNotifications,
        // requestData: model?.toJson(),
      );
      return result.when(
        success: (Response response) {
          return ApiResultModel<NotificationsResponseModel?>.success(
            data: NotificationsResponseModel.fromJson(response.data),
          );
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<NotificationsResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<UnreadCountModel?>> getUnReadCount() async {
    try {
      final ApiResultModel<Response> result = (await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: NotificationsUnreadCount,
      ));
      return result.when(
        success: (Response response) {
          return ApiResultModel<UnreadCountModel?>.success(
            data: UnreadCountModel.fromJson(response.data['data']),
          );
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<UnreadCountModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<String?>> markNotificationRead({required String id}) async {
    try {
      final ApiResultModel<Response> result = (await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: notificationRead(id),
      ));
      return result.when(
        success: (Response response) {
          return ApiResultModel<String?>.success(data: response.data.toString());
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<String?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<String?>> markAllNotificationsRead() async {
    try {
      final ApiResultModel<Response> result = (await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: NotificationsReadAll,
      ));
      return result.when(
        success: (Response response) {
          return ApiResultModel<String?>.success(data: response.data.toString());
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<String?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<String?>> clearNotifications() async {
    try {
      final ApiResultModel<Response> result = (await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: 'ClearNotification',
      ));
      return result.when(
        success: (Response response) {
          return ApiResultModel<String?>.success(data: response.data.toString());
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<String?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }
}
