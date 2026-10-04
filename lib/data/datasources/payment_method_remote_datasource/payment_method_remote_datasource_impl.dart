import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/payment_method_remote_datasource/payment_method_remote_datasource.dart';
import 'package:futblha/data/models/response_model/payment_method_response_model/payment_methods_list_response_model.dart';
import 'package:futblha/data/network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import 'package:futblha/data/network/dio_strategy_helper/dio_request_context.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/constants/app_constants.dart';
import 'package:futblha/application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';

@Injectable(as: PaymentMethodRemoteDataSource)
class PaymentMethodRemoteDataSourceImpl implements PaymentMethodRemoteDataSource {
  const PaymentMethodRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<PaymentMethodsListResponseModel?>> getPaymentMethods() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: PaymentMethod,
      );
      return result.when(
        success: (Response response) async {
          final result = PaymentMethodsListResponseModel.fromJson(response.data);
          return ApiResultModel<PaymentMethodsListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<PaymentMethodsListResponseModel?>.failure(
            errorResultEntity: errorModel,
          );
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
