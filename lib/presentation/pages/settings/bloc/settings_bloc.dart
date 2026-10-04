import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart'; // Use Equatable
import 'package:injectable/injectable.dart';
import 'package:futblha/data/datasources/settings_remote_datasource/settings_remote_datasource.dart';
import 'package:futblha/domain/entities/settings_entity.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../data/models/response_model/settings_response_model/settings_response_model.dart';
// Import ErrorResultModel

part 'settings_event.dart';
part 'settings_state.dart';

@singleton
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRemoteDataSource _settingsRemoteDataSource;
  SettingsResponseModel? settingsResponseMod;
  SettingsBloc(this._settingsRemoteDataSource) : super(SettingsInitial()) {
    on<GetSettingsEvent>((event, emit) async {
      emit(SettingsLoading());
      final ApiResultModel<SettingsResponseModel?> result = await _settingsRemoteDataSource
          .getSettings();
      result.when(
        success: (settingsResponseModel) {
          if (settingsResponseModel != null) {
            settingsResponseMod = settingsResponseModel;
            final settingsEntity = SettingsEntity(
              terms: settingsResponseModel.terms,
              privacyPolicy: settingsResponseModel.privacy,
              instagram: settingsResponseModel.instagram,
              twitter: settingsResponseModel.twitter,
              tiktok: settingsResponseModel.tiktok,
              phone: settingsResponseModel.phone,
              email: settingsResponseModel.email,
              aboutUs: settingsResponseModel.aboutUs,
              // androidVersion: settingsResponseModel.androidVersion,
              // iosVersion: settingsResponseModel.iosVersion,
              // forcedUpdateAndroid: settingsResponseModel.forcedUpdateAndroid,
              // forcedUpdateIos: settingsResponseModel.forcedUpdateIos,
              walletUsagePercentage: settingsResponseModel.walletUsagePercentage,
            );
            emit(SettingsLoaded(settingsEntity));
          } else {
            emit(const SettingsError('Failed to load settings: Data is null.'));
          }
        },
        failure: (errorResultEntity) {
          emit(SettingsError(errorResultEntity.message ?? 'An unknown error occurred.'));
        },
      );
    });
  }
}
