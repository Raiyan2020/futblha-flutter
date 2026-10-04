// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../commundomain/entitties/based_api_result/error_result_model.dart';
import '../../constants/app_constants.dart';

extension ExtensionOnHttpResponse on http.Response {
  ApiResultModel<http.Response> performHttpRequest() {
    try {
      Map<String, dynamic> jsonData = json.decode(body);

      bool isSucceeded = jsonData['isSucceeded'] ?? false;

      if (isSucceeded) {
        if (kDebugMode) {
          print('Response[$statusCode] => ${request?.url.toString()}');
          print('Headers: $headers');
          print('Data: $body');
        }
        return ApiResultModel<http.Response>.success(data: this);
      } else {
        if (kDebugMode) {
          print('Error[${jsonData['status']['code']}] =>');
          print('Error message: ${jsonData['status']['message']}');
          print('Error message: $body');
        }
        return ApiResultModel<http.Response>.failure(
          errorResultEntity: ErrorResultModel(
            message: jsonData['status']['message'],
            statusCode: jsonData['status']['code'],
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      return const ApiResultModel<http.Response>.failure(
        errorResultEntity: ErrorResultModel(
          message: formatExceptionMessage,
          statusCode: formatExceptionStatusCode,
        ),
      );
    }
  }
}
