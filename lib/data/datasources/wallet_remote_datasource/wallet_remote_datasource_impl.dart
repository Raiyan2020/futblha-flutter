import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../models/response_model/wallet/add_balance_response_model.dart';
import '../../models/response_model/wallet/transactions_response_model.dart';
import '../../models/request_model/wallet/add_balance_request_model.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'wallet_remote_datasource.dart';

@Injectable(as: WalletRemoteDataSource)
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  const WalletRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<AddBalanceResponseModel?>> addBalance({
    required AddBalanceRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: AddBalance,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final result = AddBalanceResponseModel.fromJson(response.data['data']);
          return ApiResultModel<AddBalanceResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<AddBalanceResponseModel?>.failure(
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

  @override
  Future<ApiResultModel<TransactionsResponseModel?>> getTransactions() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Transactions,
      );
      return result.when(
        success: (Response response) async {
          final result = TransactionsResponseModel.fromJson(response.data);
          return ApiResultModel<TransactionsResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<TransactionsResponseModel?>.failure(
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

