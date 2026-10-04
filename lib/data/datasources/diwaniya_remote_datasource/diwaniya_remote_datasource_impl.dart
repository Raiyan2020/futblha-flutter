import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../models/response_model/diwaniya/diwaniya_type_model.dart';
import '../../models/response_model/diwaniya/diwaniya_model.dart';
import '../../models/response_model/diwaniya/diwaniyas_list_response_model.dart';
import '../../models/response_model/diwaniya/diwaniya_members_response_model.dart';
import '../../models/response_model/diwaniya/message_model.dart';
import '../../models/response_model/diwaniya/messages_response_model.dart';
import '../../models/response_model/diwaniya/diwaniya_ranking_response_model.dart';
import '../../models/response_model/diwaniya/diwaniyas_overview_response_model.dart';
import '../../models/request_model/diwaniya/create_diwaniya_request_model.dart';
import '../../models/request_model/diwaniya/send_message_request_model.dart';
import '../../models/request_model/diwaniya/poll_vote_request_model.dart';
import '../../models/response_model/games/game_history_response_model.dart';
import '../../models/response_model/games/game_model.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'diwaniya_remote_datasource.dart';

@Injectable(as: DiwaniyaRemoteDataSource)
class DiwaniyaRemoteDataSourceImpl implements DiwaniyaRemoteDataSource {
  const DiwaniyaRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  /// Normalizes diwaniya data before parsing to handle API inconsistencies
  /// (e.g., user_permission as empty array instead of null/object)
  Map<String, dynamic> _normalizeDiwaniyaData(Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);
    // Handle case where user_permission is an empty array instead of null/object
    if (normalized['user_permission'] is List) {
      normalized['user_permission'] = null;
    }
    return normalized;
  }

  /// Normalizes nested diwaniya objects in games (creator_diwanya, opponent_diwanya)
  Map<String, dynamic> _normalizeGameData(Map<String, dynamic> gameData) {
    final normalized = Map<String, dynamic>.from(gameData);

    // Normalize creator_diwanya
    if (normalized['creator_diwanya'] is Map) {
      normalized['creator_diwanya'] = _normalizeDiwaniyaData(
        Map<String, dynamic>.from(normalized['creator_diwanya']),
      );
    }

    // Normalize opponent_diwanya
    if (normalized['opponent_diwanya'] is Map) {
      normalized['opponent_diwanya'] = _normalizeDiwaniyaData(
        Map<String, dynamic>.from(normalized['opponent_diwanya']),
      );
    }

    return normalized;
  }

  @override
  Future<ApiResultModel<List<DiwaniyaTypeModel>?>> getDiwaniyaTypes() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: DiwaniyaTypes,
      );
      return result.when(
        success: (Response response) async {
          final List<dynamic> data = response.data['data'] ?? [];
          final List<DiwaniyaTypeModel> types = data
              .map((json) => DiwaniyaTypeModel.fromJson(json))
              .toList();
          return ApiResultModel<List<DiwaniyaTypeModel>?>.success(data: types);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<List<DiwaniyaTypeModel>?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<DiwaniyaModel?>> createDiwaniya({
    required CreateDiwaniyaRequestModel request,
  }) async {
    try {
      final formDataMap = request.toFormData();
      final formData = FormData.fromMap({
        'name': formDataMap['name'],
        'description': formDataMap['description'],
        'type': formDataMap['type'],
      });

      if (formDataMap['image'] != null && formDataMap['image'] is File) {
        final file = formDataMap['image'] as File;
        formData.files.add(MapEntry('image', await MultipartFile.fromFile(file.path)));
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Diwaniyas,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final data = _normalizeDiwaniyaData(Map<String, dynamic>.from(response.data['data']));
          final result = DiwaniyaModel.fromJson(data);
          return ApiResultModel<DiwaniyaModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyaModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<DiwaniyaModel?>> getDiwaniya({required int diwaniyaId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId',
      );
      return result.when(
        success: (Response response) async {
          final data = _normalizeDiwaniyaData(Map<String, dynamic>.from(response.data['data']));
          final result = DiwaniyaModel.fromJson(data);
          return ApiResultModel<DiwaniyaModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyaModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<DiwaniyaModel?>> updateDiwaniya({
    required int diwaniyaId,
    required CreateDiwaniyaRequestModel request,
  }) async {
    try {
      final formDataMap = request.toFormData();
      final formData = FormData.fromMap({
        'name': formDataMap['name'],
        'description': formDataMap['description'],
        'type': formDataMap['type'],
      });

      if (formDataMap['image'] != null && formDataMap['image'] is File) {
        final file = formDataMap['image'] as File;
        formData.files.add(MapEntry('image', await MultipartFile.fromFile(file.path)));
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId',
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final data = _normalizeDiwaniyaData(Map<String, dynamic>.from(response.data['data']));
          final result = DiwaniyaModel.fromJson(data);
          return ApiResultModel<DiwaniyaModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyaModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<DiwaniyasListResponseModel?>> getOtherDiwaniyas() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Diwaniyas/other',
      );
      return result.when(
        success: (Response response) async {
          final data = Map<String, dynamic>.from(response.data['data']);

          // Normalize items array to handle user_permission as empty array
          if (data['items'] is List) {
            final items = (data['items'] as List).map((item) {
              if (item is Map) {
                return _normalizeDiwaniyaData(Map<String, dynamic>.from(item));
              }
              return item;
            }).toList();
            data['items'] = items;
          }

          final result = DiwaniyasListResponseModel.fromJson(data);
          return ApiResultModel<DiwaniyasListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyasListResponseModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<DiwaniyasOverviewResponseModel?>> getDiwaniyasOverview({
    String? type,
    int? membersCount,
    int? rating,
    String? name,
    int? page,
    int? per_page,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (type != null) queryParams['type'] = type;
      if (membersCount != null) queryParams['members_count'] = membersCount;
      if (rating != null) queryParams['rating'] = rating;
      if (name != null) queryParams['name'] = name;
      if (page != null) queryParams['page'] = page;
      if (per_page != null) queryParams['per_page'] = per_page;

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: DiwaniyasOverview,
        requestData: queryParams.isNotEmpty ? queryParams : null,
      );
      return result.when(
        success: (Response response) async {
          final data = Map<String, dynamic>.from(response.data['data']);

          // Normalize my_diwaniya
          if (data['my_diwaniya'] is Map) {
            final myDiwaniya = _normalizeDiwaniyaData(
              Map<String, dynamic>.from(data['my_diwaniya']),
            );

            // Normalize nested upcoming_games and their diwaniya objects
            if (myDiwaniya['upcoming_games'] is List) {
              final upcomingGames = (myDiwaniya['upcoming_games'] as List).map((game) {
                if (game is Map) {
                  return _normalizeGameData(Map<String, dynamic>.from(game));
                }
                return game;
              }).toList();
              myDiwaniya['upcoming_games'] = upcomingGames;
            }

            data['my_diwaniya'] = myDiwaniya;
          }

          // Normalize other_diwaniyas.items
          if (data['other_diwaniyas'] is Map && data['other_diwaniyas']['items'] is List) {
            final otherDiwaniyas = Map<String, dynamic>.from(data['other_diwaniyas']);
            final items = (otherDiwaniyas['items'] as List).map((item) {
              if (item is Map) {
                return _normalizeDiwaniyaData(Map<String, dynamic>.from(item));
              }
              return item;
            }).toList();
            otherDiwaniyas['items'] = items;
            data['other_diwaniyas'] = otherDiwaniyas;
          }

          final result = DiwaniyasOverviewResponseModel.fromJson(data);
          return ApiResultModel<DiwaniyasOverviewResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyasOverviewResponseModel?>.failure(
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
  Future<ApiResultModel<DiwaniyaMembersResponseModel?>> getDiwaniyaMembers({
    required int diwaniyaId,
  }) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/members',
      );
      return result.when(
        success: (Response response) async {
          final result = DiwaniyaMembersResponseModel.fromJson(response.data['data']);
          return ApiResultModel<DiwaniyaMembersResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyaMembersResponseModel?>.failure(
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
  Future<ApiResultModel<DiwaniyaMembersResponseModel?>> getJoinRequests({
    required int diwaniyaId,
  }) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/join-requests',
      );
      return result.when(
        success: (Response response) async {
          final result = DiwaniyaMembersResponseModel.fromJson(response.data['data']);
          return ApiResultModel<DiwaniyaMembersResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyaMembersResponseModel?>.failure(
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
  Future<ApiResultModel<String?>> joinDiwaniya({required int diwaniyaId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/join',
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data'] as String?;
          return ApiResultModel<String?>.success(data: message);
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
  Future<ApiResultModel<String?>> approveJoinRequest({
    required int diwaniyaId,
    required int userId,
  }) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/approve-join-request',
        requestData: {'user_id': userId.toString()},
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data'] as String?;
          return ApiResultModel<String?>.success(data: message);
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
  Future<ApiResultModel<String?>> removeMember({
    required int diwaniyaId,
    required int userId,
  }) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/delete',
        requestData: {'user_id': userId.toString()},
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data'] as String?;
          return ApiResultModel<String?>.success(data: message);
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
  Future<ApiResultModel<String?>> leaveDiwaniya({required int diwaniyaId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/leave',
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data'] as String?;
          return ApiResultModel<String?>.success(data: message);
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
  Future<ApiResultModel<String?>> deleteDiwaniya({required int diwaniyaId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/delete',
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data'] as String?;
          return ApiResultModel<String?>.success(data: message);
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
  Future<ApiResultModel<MessageModel?>> sendMessage({
    required int diwaniyaId,
    required SendMessageRequestModel request,
  }) async {
    try {
      final formDataMap = request.toFormData();
      final formData = FormData.fromMap(formDataMap);

      // Handle file upload for image/file types
      if ((request.type == 'image' || request.type == 'file') && request.file != null) {
        formData.files.add(MapEntry('content', await MultipartFile.fromFile(request.file!.path)));
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/messages',
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final result = MessageModel.fromJson(response.data['data']);
          return ApiResultModel<MessageModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<MessageModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<MessagesResponseModel?>> getMessages({
    required int diwaniyaId,
    int? page,
  }) async {
    try {
      final queryParams = page != null ? '?page=$page' : '';
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/messages$queryParams',
      );
      return result.when(
        success: (Response response) async {
          final result = MessagesResponseModel.fromJson(response.data['data']);
          return ApiResultModel<MessagesResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<MessagesResponseModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<String?>> votePoll({required PollVoteRequestModel request}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Vote,
        requestData: request.toFormData(),
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data'] as String?;
          return ApiResultModel<String?>.success(data: message);
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
  Future<ApiResultModel<DiwaniyaRankingResponseModel?>> getDiwaniyaRanking({String? date}) async {
    try {
      final Map<String, dynamic>? queryParams = date != null ? {'date': date} : null;

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: DiwaniyaRanking,
        requestData: queryParams,
      );
      return result.when(
        success: (Response response) async {
          final data = Map<String, dynamic>.from(response.data['data']);

          // Normalize top_ranking diwaniyas to handle user_permission as empty array
          if (data['top_ranking'] is List) {
            final topRanking = (data['top_ranking'] as List).map((item) {
              if (item is Map) {
                return _normalizeDiwaniyaData(Map<String, dynamic>.from(item));
              }
              return item;
            }).toList();
            data['top_ranking'] = topRanking;
          }

          // Normalize all_ranking.items diwaniyas to handle user_permission as empty array
          if (data['all_ranking'] is Map && data['all_ranking']['items'] is List) {
            final allRanking = Map<String, dynamic>.from(data['all_ranking']);
            final items = (allRanking['items'] as List).map((item) {
              if (item is Map) {
                return _normalizeDiwaniyaData(Map<String, dynamic>.from(item));
              }
              return item;
            }).toList();
            allRanking['items'] = items;
            data['all_ranking'] = allRanking;
          }

          final result = DiwaniyaRankingResponseModel.fromJson(data);
          return ApiResultModel<DiwaniyaRankingResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<DiwaniyaRankingResponseModel?>.failure(
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
  Future<ApiResultModel<GameHistoryResponseModel?>> getDiwaniyaGames({
    required int diwaniyaId,
    int? page,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) {
        queryParams['page'] = page;
      }
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Diwaniyas/$diwaniyaId/games',
        requestData: queryParams,
      );
      return result.when(
        success: (Response response) async {
          final data = response.data['data'];

          // Handle both paginated and non-paginated responses
          if (data is Map && data.containsKey('items')) {
            // Paginated response - normalize games in items array
            final normalizedData = Map<String, dynamic>.from(data);
            if (normalizedData['items'] is List) {
              final items = (normalizedData['items'] as List).map((item) {
                if (item is Map) {
                  return _normalizeGameData(Map<String, dynamic>.from(item));
                }
                return item;
              }).toList();
              normalizedData['items'] = items;
            }
            final result = GameHistoryResponseModel.fromJson(normalizedData);
            return ApiResultModel<GameHistoryResponseModel?>.success(data: result);
          } else if (data is List) {
            // Simple array response - convert to paginated format
            final result = GameHistoryResponseModel(
              items: data.map((item) {
                if (item is Map) {
                  final normalized = _normalizeGameData(Map<String, dynamic>.from(item));
                  return GameModel.fromJson(normalized);
                }
                return GameModel.fromJson(item as Map<String, dynamic>);
              }).toList(),
              paginate: null,
            );
            return ApiResultModel<GameHistoryResponseModel?>.success(data: result);
          } else {
            return ApiResultModel<GameHistoryResponseModel?>.failure(
              errorResultEntity: ErrorResultModel(message: 'Invalid response format'),
            );
          }
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameHistoryResponseModel?>.failure(errorResultEntity: errorModel);
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
