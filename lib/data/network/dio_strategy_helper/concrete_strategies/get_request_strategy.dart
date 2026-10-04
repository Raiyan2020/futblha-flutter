import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/dio_response_extensions.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../dio_request_strategy.dart';

@lazySingleton
@injectable
class GetRequestStrategy implements DioRequestStrategy {
  final Dio _dio;

  GetRequestStrategy(this._dio);

  @override
  Future<ApiResultModel<Response>> executeRequest({
    required String uri,
    Map<String, String> headers = const <String, String>{},
    dynamic requestData = const <String, dynamic>{},
    dynamic formData,
  }) async {
    final Response response = await _dio.get(
      uri,
      queryParameters: requestData,
      options: Options(headers: headers),
    );
    return response.performHttpRequest();
  }
}
