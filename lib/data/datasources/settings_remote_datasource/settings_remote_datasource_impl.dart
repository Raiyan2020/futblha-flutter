import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/settings_remote_datasource/settings_remote_datasource.dart';
import 'package:futblha/data/models/response_model/settings_response_model/settings_response_model.dart';
import 'package:futblha/data/network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import 'package:futblha/data/network/dio_strategy_helper/dio_request_context.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import 'package:futblha/application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/constants/app_constants.dart';
import 'package:futblha/application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';

@Injectable(as: SettingsRemoteDataSource)
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  const SettingsRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<SettingsResponseModel?>> getSettings() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Settings,
      );
      return result.when(
        success: (Response response) async {
          final result = SettingsResponseModel.fromJson(response.data['data']);
          return ApiResultModel<SettingsResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<SettingsResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }
}
