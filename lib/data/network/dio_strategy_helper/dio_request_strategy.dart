import 'package:dio/dio.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';

abstract class DioRequestStrategy {
  Future<ApiResultModel<Response>> executeRequest({
    required String uri,
    Map<String, String> headers = const <String, String>{},
    Map<String, dynamic> requestData = const <String, dynamic>{},
    dynamic formData ,
  });
}
