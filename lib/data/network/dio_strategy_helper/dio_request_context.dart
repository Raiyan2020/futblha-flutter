import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/constants/app_constants.dart';
import '../../../application/core/utils/helpers/app_flavor_helper/app_flavors_helper.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../presentation/pages/auth/bloc/authentication_bloc.dart';
import 'dio_request_strategy.dart';

@injectable
class DioRequestContext {
  Map<String, String> _sharedDefaultHeader = <String, String>{};

  Future<void> initSharedDefaultHeader([String contentValue = contentTypeValue]) async {
    _sharedDefaultHeader = <String, String>{};
    _sharedDefaultHeader.addAll(<String, String>{
      acceptKey: contentValue,
      contentTypeKey: contentValue,
      authorisationKey: CacheManager.instance.getAuthToken().isNotEmpty ? bearerKey + CacheManager.instance.getAuthToken() : '',
      acceptLanguageKey: CacheManager.instance.getLanguage() ?? 'en',
    });
  }

  Future<ApiResultModel<Response>> makeRequest({
    required String uri,
    required DioRequestStrategy dioRequestStrategy,
    Map<String, String> headers = const <String, String>{},
    dynamic requestData,
    dynamic formData,
  }) async {
    await initSharedDefaultHeader();
    _sharedDefaultHeader.addAll(headers);

    try {
      final String url = '${locator<AppFlavorsHelper>().baseUrl}$uri';
      final ApiResultModel<Response> result = await dioRequestStrategy.executeRequest(
        uri: url,
        headers: _sharedDefaultHeader,
        requestData: requestData ?? {},
        formData: formData,
      );
      return result;
    } on DioException catch (e) {
      debugPrint('DioException : $e');
      if (e.response != null) {
        if (e.response?.statusCode == unAuthorizedStatusCode) {
          locator<AuthenticationBloc>().add(const LogoutEvent(apiRequest: false));
          return const ApiResultModel<Response>.failure(
            errorResultEntity: ErrorResultModel(message: 'Unauthorized', statusCode: unAuthorizedStatusCode),
          );
        }
        return ApiResultModel<Response>.failure(
          errorResultEntity: ErrorResultModel(
            message: _extractErrorMessage(e.response?.data, e.response?.statusCode),
            statusCode: e.response?.statusCode,
          ),
        );
      }
      return const ApiResultModel<Response>.failure(
        errorResultEntity: ErrorResultModel(message: commonConnectionFailedMessage, statusCode: ioExceptionStatusCode),
      );
    } on TimeoutException catch (_) {
      return const ApiResultModel<Response>.failure(
        errorResultEntity: ErrorResultModel(message: commonErrorUnexpectedMessage, statusCode: timeoutRequestStatusCode),
      );
    } on IOException catch (_) {
      return const ApiResultModel<Response>.failure(
        errorResultEntity: ErrorResultModel(message: commonConnectionFailedMessage, statusCode: ioExceptionStatusCode),
      );
    } on FormatException catch (e) {
      debugPrint('Unexpected error: $e');
      return const ApiResultModel<Response>.failure(
        errorResultEntity: ErrorResultModel(message: formatExceptionMessage, statusCode: formatExceptionStatusCode),
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return const ApiResultModel<Response>.failure(
        errorResultEntity: ErrorResultModel(message: commonErrorUnexpectedMessage, statusCode: timeoutRequestStatusCode),
      );
    }
  }
}

String _extractErrorMessage(dynamic data, int? statusCode) {
  if (data is String && data.isNotEmpty) {
    return data;
  }
  if (data is Map) {
    final dynamic message = data['msg'] ?? data['message'] ?? data['error'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
  }
  return 'Request failed with status $statusCode';
}
