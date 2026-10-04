import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../../commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../commundomain/entitties/based_api_result/error_result_model.dart';
import '../../constants/app_constants.dart';

extension ExtensionOnDioResponse on Response {
  ApiResultModel<Response> performHttpRequest() {
    try {
      final bool isSucceeded =
          data is Map<String, dynamic> && (data.containsKey('status') || data.containsKey('status'))
              ? data['status'] ?? data['status']
              : true;

      if (isSucceeded) {
        return ApiResultModel<Response>.success(data: this);
      } else {
        return ApiResultModel<Response>.failure(
          errorResultEntity: ErrorResultModel(
            message: data['error'] ?? data['msg'] ?? data['message'] ?? 'Unknown error',
            statusCode: statusCode,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      return const ApiResultModel<Response>.failure(
        errorResultEntity: ErrorResultModel(
          message: formatExceptionMessage,
          statusCode: formatExceptionStatusCode,
        ),
      );
    }
  }
}
