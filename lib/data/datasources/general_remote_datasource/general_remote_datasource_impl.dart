import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../models/response_model/general/countries_list_response_model.dart';
import '../../models/response_model/general/cities_list_response_model.dart';
import '../../models/response_model/general/positions_list_response_model.dart';
import '../../models/response_model/general/home_response_model.dart';
import '../../models/response_model/games/game_model.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'general_remote_datasource.dart';

@Injectable(as: GeneralRemoteDataSource)
class GeneralRemoteDataSourceImpl implements GeneralRemoteDataSource {
  const GeneralRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<CountriesListResponseModel?>> getCountries() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Countries,
      );
      return result.when(
        success: (Response response) async {
          final result = CountriesListResponseModel.fromJson({'data': response.data['data']});
          return ApiResultModel<CountriesListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<CountriesListResponseModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<CitiesListResponseModel?>> getCities() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Cities,
      );
      return result.when(
        success: (Response response) async {
          final result = CitiesListResponseModel.fromJson({'data': response.data['data']});
          return ApiResultModel<CitiesListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<CitiesListResponseModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<PositionsListResponseModel?>> getPositions() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Positions,
      );
      return result.when(
        success: (Response response) async {
          final result = PositionsListResponseModel.fromJson({'data': response.data['data']});
          return ApiResultModel<PositionsListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<PositionsListResponseModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<HomeResponseModel?>> getHome() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Home,
      );
      return result.when(
        success: (Response response) async {
          final data = Map<String, dynamic>.from(response.data['data']);

          // Normalize top_ranking diwaniyas to handle user_permission as empty array
          if (data['top_ranking'] is List) {
            final topRanking = (data['top_ranking'] as List).map((item) {
              if (item is Map) {
                final normalized = Map<String, dynamic>.from(item);
                // Handle case where user_permission is an empty array instead of null/object
                if (normalized['user_permission'] is List) {
                  normalized['user_permission'] = null;
                }
                return normalized;
              }
              return item;
            }).toList();
            data['top_ranking'] = topRanking;
          }

          // Normalize upcoming_games (each game's creator_diwanya, opponent_diwanya)
          if (data['upcoming_games'] is List) {
            final upcomingGames = (data['upcoming_games'] as List).map((item) {
              if (item is Map) {
                final gameData = Map<String, dynamic>.from(item);
                if (gameData['creator_diwanya'] is Map) {
                  gameData['creator_diwanya'] = _normalizeDiwaniyaInGame(
                    Map<String, dynamic>.from(gameData['creator_diwanya']),
                  );
                }
                if (gameData['opponent_diwanya'] is Map) {
                  gameData['opponent_diwanya'] = _normalizeDiwaniyaInGame(
                    Map<String, dynamic>.from(gameData['opponent_diwanya']),
                  );
                }
                return gameData;
              }
              return item;
            }).toList();
            data['upcoming_games'] = upcomingGames;
          }

          final result = HomeResponseModel.fromJson(data);
          return ApiResultModel<HomeResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<HomeResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  Map<String, dynamic> _normalizeDiwaniyaInGame(Map<String, dynamic> map) {
    final normalized = Map<String, dynamic>.from(map);
    if (normalized['user_permission'] is List) {
      normalized['user_permission'] = null;
    }
    return normalized;
  }

  @override
  Future<ApiResultModel<List<GameModel>?>> getUpcomingGames() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: GamesUpcoming,
      );
      return result.when(
        success: (Response response) async {
          final rawList = response.data['data'];
          if (rawList is! List) {
            return ApiResultModel<List<GameModel>?>.success(data: []);
          }
          final list = rawList.map<GameModel>((item) {
            final gameData = Map<String, dynamic>.from(item as Map);
            if (gameData['creator_diwanya'] is Map) {
              gameData['creator_diwanya'] = _normalizeDiwaniyaInGame(
                Map<String, dynamic>.from(gameData['creator_diwanya']),
              );
            }
            if (gameData['opponent_diwanya'] is Map) {
              gameData['opponent_diwanya'] = _normalizeDiwaniyaInGame(
                Map<String, dynamic>.from(gameData['opponent_diwanya']),
              );
            }
            return GameModel.fromJson(gameData);
          }).toList();
          return ApiResultModel<List<GameModel>?>.success(data: list);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<List<GameModel>?>.failure(errorResultEntity: errorModel);
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
