import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/models/request_model/contact/contact_model.dart';
import 'package:futblha/data/models/request_model/social/social_response_model.dart';
import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/constants/app_constants.dart';
import '../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'contact_remote_datasource.dart';

@Injectable(as: ContactRemoteDataSource)
class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  // Renamed class
  const ContactRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<String?>> contact(ContactModel model) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Contact,
        requestData: model.toJson(),
      );
      return result.when(
        success: (Response response) {
          return ApiResultModel<String?>.success(
            data: response.data['message'],
          ); // Changed to 'message'
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
  Future<ApiResultModel<SocialResponseModel?>> getSocialLinks() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: 'GetSocialLinks',
      );
      return result.when(
        success: (Response response) {
          return ApiResultModel<SocialResponseModel?>.success(
            data: SocialResponseModel.fromJson(response.data['data']),
          );
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<SocialResponseModel?>.failure(errorResultEntity: errorModel);
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
