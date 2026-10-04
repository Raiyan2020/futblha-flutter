import 'package:futblha/data/models/response_model/settings_response_model/settings_response_model.dart';

import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';

abstract class SettingsRemoteDataSource {
  Future<ApiResultModel<SettingsResponseModel?>> getSettings();
}
