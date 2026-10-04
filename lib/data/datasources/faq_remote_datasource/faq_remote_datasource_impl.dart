import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/faq_remote_datasource/faq_remote_datasource.dart';
import 'package:futblha/data/models/response_model/faq_response_model/faqs_list_response_model.dart';
import 'package:futblha/data/network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import 'package:futblha/data/network/dio_strategy_helper/dio_request_context.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';

@Injectable(as: FaqRemoteDataSource)
class FaqRemoteDataSourceImpl implements FaqRemoteDataSource {
  const FaqRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<FaqsListResponseModel?>> getFaqs() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: 'Faqs',
      );
      return result.when(
        success: (Response response) async {
          final result = FaqsListResponseModel.fromJson(response.data);
          return ApiResultModel<FaqsListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<FaqsListResponseModel?>.failure(errorResultEntity: errorModel);
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
