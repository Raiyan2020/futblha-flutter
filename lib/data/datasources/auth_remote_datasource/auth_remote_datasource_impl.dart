import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/constants/app_constants.dart';
import '../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../models/request_model/auth/login/login_request_model.dart';
import '../../models/request_model/auth/logout/logout_request_model.dart';
import '../../models/request_model/auth/update_user_settings_request_model.dart';
import '../../models/request_model/auth/verify_otp_request_model.dart';
import '../../models/response_model/auth/register_response_model.dart';
import '../../models/response_model/auth/resend_activation_response_model.dart';
import '../../models/response_model/auth/delete_account_response_model.dart';
import '../../models/response_model/login_remote_response_model/login_response_model.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'auth_remote_datasource.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<LoginResponseModel?>> doLogin({LoginRequestModel? requestModel}) async {
    try {
      FormData? formData;
      if (requestModel != null) {
        formData = FormData.fromMap({
          if (requestModel.phone != null) 'phone': requestModel.phone,
          if (requestModel.countryCode != null) 'country_code': requestModel.countryCode,
          if (requestModel.deviceToken != null) 'fcm_token': requestModel.deviceToken,
        });
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Login,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          // The API returns {"status": true, "data": "login successfully"}
          // We need to handle the case where data is a string
          final data = response.data['data'];
          LoginResponseModel result;
          if (data is String) {
            // Login just returns a success message, user data comes from verify-otp
            result = LoginResponseModel(token: null, user: null);
          } else {
            // If it's an object, parse it normally
            result = LoginResponseModel.fromJson(data);
          }
          return ApiResultModel<LoginResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<LoginResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  @override
  Future<ApiResultModel<RegisterResponseModel?>> register({LoginRequestModel? requestModel}) async {
    try {
      FormData? formData;
      if (requestModel != null) {
        formData = FormData.fromMap({
          if (requestModel.name != null) 'name': requestModel.name,
          if (requestModel.phone != null) 'phone': requestModel.phone,
          if (requestModel.countryCode != null) 'country_code': requestModel.countryCode,
          if (requestModel.deviceToken != null) 'fcm_token': requestModel.deviceToken,
          if (requestModel.birthdate != null) 'birthdate': requestModel.birthdate,
        });
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Register,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          // The API returns {"status": true, "data": "register successfully"}
          // We need to handle the case where data is a string
          final data = response.data['data'];
          final result = RegisterResponseModel(
            message: data is String ? data : data?['message'],
          );
          return ApiResultModel<RegisterResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<RegisterResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  @override
  Future<ApiResultModel<LoginResponseModel?>> verifyOtp({VerifyOtpRequestModel? requestModel}) async {
    try {
      FormData? formData;
      if (requestModel != null) {
        formData = FormData.fromMap({
          if (requestModel.phone != null) 'phone': requestModel.phone,
          if (requestModel.activationCode != null) 'code': requestModel.activationCode,
          if (requestModel.countryCode != null) 'country_code': requestModel.countryCode,
        });
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: ActivateAccount,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          // The API returns {"status": true, "data": {"id": 2, "name": "...", "token": "...", ...}}
          // But LoginResponseModel expects {"token": "...", "user": {"id": 2, "name": "...", ...}}
          final data = response.data['data'] as Map<String, dynamic>?;
          if (data == null) {
            return ApiResultModel<LoginResponseModel?>.failure(
              errorResultEntity: ErrorResultModel(
                message: 'Invalid response format',
                statusCode: 400,
              ),
            );
          }
          
          // Extract token from data
          final token = data['token'] as String?;
          
          // Create user data without token
          final userData = Map<String, dynamic>.from(data);
          userData.remove('token'); // Remove token from user data
          
          // Create UserModel from the data
          final user = UserModel.fromJson(userData);
          
          // Create LoginResponseModel with token and user
          final result = LoginResponseModel(token: token, user: user);
          return ApiResultModel<LoginResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<LoginResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  // ResendActivation endpoint has been removed - functionality no longer available
  @override
  Future<ApiResultModel<ResendActivationResponseModel?>> resendOtp({LoginRequestModel? requestModel}) async {
    // This endpoint is no longer available in the API
    return ApiResultModel<ResendActivationResponseModel?>.failure(
      errorResultEntity: ErrorResultModel(
        message: 'Resend OTP functionality is no longer available',
        statusCode: 404,
      ),
    );
  }

  @override
  Future<ApiResultModel<String?>> logout({LogoutRequestModel? model}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Logout,
        requestData: model?.toJson(),
      );
      return result.when(
        success: (Response response) async {
          return ApiResultModel<String?>.success(data:response.data['data'] );
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<String?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  @override
  Future<ApiResultModel<UserModel?>> getProfileData({String? userId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: GetProfile,
       // requestData: {'userId': userId},
      );
      return result.when(
        success: (Response response) async {
          final result = UserModel.fromJson(response.data['data']);
          return ApiResultModel<UserModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<UserModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  @override
  Future<ApiResultModel<UserModel?>> updateProfile({
    LoginRequestModel? requestModel,
    File? image,
    List<String>? positions,
    String? birthdate,
  }) async {
    try {
      FormData? formData;
      final Map<String, dynamic> formDataMap = {};
      
      // Add text fields
      if (requestModel?.name != null) formDataMap['name'] = requestModel!.name;
      if (requestModel?.phone != null) formDataMap['phone'] = requestModel!.phone;
      if (requestModel?.countryCode != null) formDataMap['country_code'] = requestModel!.countryCode;
      if (requestModel?.email != null && requestModel!.email!.isNotEmpty) formDataMap['email'] = requestModel.email;
      if (birthdate != null && birthdate.isNotEmpty) formDataMap['birthdate'] = birthdate;
      
      // Add positions array
      if (positions != null && positions.isNotEmpty) {
        for (int i = 0; i < positions.length; i++) {
          formDataMap['position[$i]'] = positions[i];
        }
      }
      
      // Add image if provided
      if (image != null) {
        formDataMap['image'] = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        );
      }
      
      // Use FormData if we have any fields, otherwise use JSON
      if (formDataMap.isNotEmpty || image != null) {
        formData = FormData.fromMap(formDataMap);
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: UpdateProfile,
        requestData: formData == null ? requestModel?.toJson() : null,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final result = UserModel.fromJson(response.data['data']);
          return ApiResultModel<UserModel?>.success(data: result);
        },
        failure: (ErrorResultModel error) {
          return ApiResultModel<UserModel?>.failure(errorResultEntity: error);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  @override
  Future<ApiResultModel<UserModel?>> updateUserSettings({UpdateUserSettingsRequestModel? requestModel}) async {
    try {
      FormData? formData;
      if (requestModel != null) {
        formData = FormData.fromMap({
          if (requestModel.notificationEnabled != null) 'notified': requestModel.notificationEnabled,
          if (requestModel.language != null) 'language': requestModel.language,
        });
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: UpdateUserSettings,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final result = UserModel.fromJson(response.data['data']);
          return ApiResultModel<UserModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<UserModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  @override
  Future<ApiResultModel<UserModel?>> completeProfile({File? image, List<String>? positions}) async {
    try {
      FormData? formData;
      if (image != null || positions != null) {
        final Map<String, dynamic> formDataMap = {};
        
        if (image != null) {
          formDataMap['image'] = await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          );
        }
        
        if (positions != null && positions.isNotEmpty) {
          for (int i = 0; i < positions.length; i++) {
            formDataMap['position[$i]'] = positions[i];
          }
        }
        
        formData = FormData.fromMap(formDataMap);
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: CompleteProfile,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final result = UserModel.fromJson(response.data['data']);
          return ApiResultModel<UserModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<UserModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }

  @override
  Future<ApiResultModel<DeleteAccountResponseModel?>> deleteAccount() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: DeleteAccount,
      );
      return result.when(
        success: (Response response) async {
          final result = DeleteAccountResponseModel.fromJson(response.data);
          return ApiResultModel<DeleteAccountResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DeleteAccountResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(exceptionMessage: exception.exceptionMessage, exceptionCode: exception.exceptionCode);
    }
  }
}
