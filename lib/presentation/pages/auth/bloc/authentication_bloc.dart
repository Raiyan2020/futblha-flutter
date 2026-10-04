import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/auth_remote_datasource/auth_remote_datasource.dart';
import 'package:futblha/data/models/response_model/login_remote_response_model/login_response_model.dart';
import 'package:futblha/data/models/response_model/auth/register_response_model.dart';
import 'package:futblha/data/models/response_model/auth/resend_activation_response_model.dart';
import 'package:futblha/data/models/response_model/auth/delete_account_response_model.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../../data/models/request_model/auth/login/login_request_model.dart';
import '../../../../data/models/request_model/auth/logout/logout_request_model.dart';
import '../../../../data/models/request_model/auth/verify_otp_request_model.dart';
import '../../../../data/models/request_model/auth/update_user_settings_request_model.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

@singleton
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRemoteDataSource _remoteDataSource;
  UserModel? user;
  /// My diwaniya from diwaniyas-overview API; used to restrict join to one team in games.
  DiwaniyaModel? myDiwaniya;
  bool firstTime = false;
  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  AuthenticationBloc(this._remoteDataSource) : super(AuthenticationInitial()) {
    on<ChangePassVisibilityEvent>(_changePasswordVisibility);
    on<LoginEvent>(_doLogin);
    on<RegisterEvent>(_register);
    on<VerifyOtpEvent>(_verifyOtp);
    on<ResendOtpEvent>(_resendOtp);
    on<GetProfileEvent>(_getProfile);
    on<UpdateProfileEvent>(_updateProfile);
    on<UpdateUserSettingsEvent>(_updateUserSettings);
    on<LogoutEvent>(_logout);
    on<CompleteProfileEvent>(_completeProfile);
    on<DeleteAccountEvent>(_deleteAccount);
    on<GuestLoginEvent>(_doGuestLogin);
    on<UpdateMyDiwaniyaEvent>(_updateMyDiwaniya);
  }

  void _updateMyDiwaniya(UpdateMyDiwaniyaEvent event, Emitter<AuthenticationState> emit) {
    myDiwaniya = event.myDiwaniya is DiwaniyaModel ? event.myDiwaniya as DiwaniyaModel? : null;
  }

  void _changePasswordVisibility(
    ChangePassVisibilityEvent event,
    Emitter<AuthenticationState> emit,
  ) {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(ChangePasswordVisibility(isPassword));
  }

  Future<void> _doLogin(LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthLoading());
    final model = event.entity.copyWith(
      deviceToken: CacheManager.instance.getFCMDeviceToken(),
      deviceType: Platform.isAndroid ? 'android' : 'ios',
    );
    final ApiResultModel<LoginResponseModel?> apiResult = await _remoteDataSource.doLogin(
      requestModel: model,
    );

    apiResult.when(
      success: (LoginResponseModel? data) {
        // Login returns a success message, user data comes from verify-otp
        // Only set user data if it's actually present
        if (data?.user != null) {
          CacheManager.instance.setUserData(data);
          user = data?.user;
        }
        emit(LoginSuccess(user: user));
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _register(RegisterEvent event, Emitter<AuthenticationState> emit) async {
    emit(RegisterLoading());
    final model = event.entity.copyWith(
      deviceToken: CacheManager.instance.getFCMDeviceToken(),
      deviceType: Platform.isAndroid ? 'android' : 'ios',
    );
    final ApiResultModel<RegisterResponseModel?> apiResult = await _remoteDataSource.register(
      requestModel: model,
    );
    apiResult.when(
      success: (RegisterResponseModel? data) {
        emit(RegisterSuccess(message: data?.message ?? ''));
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _verifyOtp(VerifyOtpEvent event, Emitter<AuthenticationState> emit) async {
    emit(VerifyOtpLoading());

    final model = event.requestModel;

    final ApiResultModel<LoginResponseModel?> apiResult = await _remoteDataSource.verifyOtp(
      requestModel: model,
    );
    apiResult.when(
      success: (LoginResponseModel? data) {
        CacheManager.instance.setUserData(data);
        // Clear guest mode when user successfully logs in
        CacheManager.instance.setGuestMode(false);
        user = data?.user;
        emit(VerifyOtpSuccess());
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _resendOtp(ResendOtpEvent event, Emitter<AuthenticationState> emit) async {
    emit(ResendOtpLoading());

    final model = event.requestModel;

    final ApiResultModel<ResendActivationResponseModel?> apiResult = await _remoteDataSource
        .resendOtp(requestModel: model);
    apiResult.when(
      success: (ResendActivationResponseModel? data) {
        emit(ResendOtpSuccess());
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _getProfile(GetProfileEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthLoading());
    final ApiResultModel<UserModel?> apiResult = await _remoteDataSource.getProfileData(
      userId: CacheManager.instance.getUserId(),
    );
    apiResult.when(
      success: (UserModel? data) {
        user = data;
        emit(GetProfileSuccess(data!));
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _updateProfile(UpdateProfileEvent event, Emitter<AuthenticationState> emit) async {
    emit(UpdateProfileLoading());
    final ApiResultModel<UserModel?> apiResult = await _remoteDataSource.updateProfile(
      requestModel: event.requestModel,
      image: event.image,
      positions: event.positions,
      birthdate: event.birthdate,
    );
    apiResult.when(
      success: (UserModel? data) {
        user = data;
        emit(const UpdateProfileSuccess());
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _updateUserSettings(
    UpdateUserSettingsEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(AuthLoading());
    final ApiResultModel<UserModel?> apiResult = await _remoteDataSource.updateUserSettings(
      requestModel: event.requestModel,
    );
    apiResult.when(
      success: (UserModel? data) {
        user = data;
        emit(const UpdateUserSettingsSuccess());
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _logout(LogoutEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthLoading());
    if (!event.apiRequest) {
      user = null;
      myDiwaniya = null;
      await CacheManager.instance.logout();
      if (!isClosed) {
        locator<AppRouter>().pushAndPopUntil(const LoginRoute(), predicate: (route) => false);
        emit(LogoutSuccess());
      }
      return;
    }
    final requestModel = LogoutRequestModel(deviceId: CacheManager.instance.getFCMDeviceToken());
    final ApiResultModel<String?> apiResult = await _remoteDataSource.logout(
      model: event.model ?? requestModel,
    );
    await apiResult.when(
      success: (String? data) async {
        user = null;
        myDiwaniya = null;
        await CacheManager.instance.logout();
        if (!isClosed) {
          locator<AppRouter>().pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
          emit(LogoutSuccess());
        }
      },
      failure: (ErrorResultModel error) async {
        locator<AppRouter>().pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
        emit(AuthenticationError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _completeProfile(
    CompleteProfileEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(UpdateProfileLoading());
    final ApiResultModel<UserModel?> apiResult = await _remoteDataSource.completeProfile(
      image: event.image,
      positions: event.positions,
    );
    apiResult.when(
      success: (UserModel? data) {
        user = data;
        emit(const UpdateProfileSuccess());
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _deleteAccount(DeleteAccountEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthLoading());
    final ApiResultModel<DeleteAccountResponseModel?> apiResult = await _remoteDataSource
        .deleteAccount();
    apiResult.when(
      success: (DeleteAccountResponseModel? data) {
        CacheManager.instance.logout();
        emit(LogoutSuccess());
      },
      failure: (ErrorResultModel error) =>
          emit(AuthenticationError(message: error.message ?? errorMessage)),
    );
  }

  Future<void> _doGuestLogin(GuestLoginEvent event, Emitter<AuthenticationState> emit) async {
    await CacheManager.instance.setGuestMode(true);
    emit(GuestLoginSuccess());
  }
}
