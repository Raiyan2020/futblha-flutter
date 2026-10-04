import 'dart:io';

import 'package:futblha/data/models/request_model/auth/login/login_request_model.dart';
import 'package:futblha/data/models/response_model/login_remote_response_model/login_response_model.dart';
import 'package:futblha/data/models/request_model/auth/verify_otp_request_model.dart'; // Import the new model

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/request_model/auth/logout/logout_request_model.dart';
import '../../models/request_model/auth/update_user_settings_request_model.dart';
import '../../models/response_model/auth/register_response_model.dart';
import '../../models/response_model/auth/resend_activation_response_model.dart';
import '../../models/response_model/auth/delete_account_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResultModel<LoginResponseModel?>> doLogin({LoginRequestModel? requestModel});

  Future<ApiResultModel<RegisterResponseModel?>> register({LoginRequestModel? requestModel});

  Future<ApiResultModel<UserModel?>> getProfileData({String? userId});

  Future<ApiResultModel<UserModel?>> updateProfile({
    LoginRequestModel? requestModel,
    File? image,
    List<String>? positions,
    String? birthdate,
  });

  Future<ApiResultModel<String?>> logout({LogoutRequestModel? model});

  Future<ApiResultModel<UserModel?>> updateUserSettings({
    UpdateUserSettingsRequestModel? requestModel,
  });

  Future<ApiResultModel<LoginResponseModel?>> verifyOtp({VerifyOtpRequestModel? requestModel});
  Future<ApiResultModel<ResendActivationResponseModel?>> resendOtp({
    LoginRequestModel? requestModel,
  });
  Future<ApiResultModel<UserModel?>> completeProfile({File? image, List<String>? positions});
  Future<ApiResultModel<DeleteAccountResponseModel?>> deleteAccount();
}
