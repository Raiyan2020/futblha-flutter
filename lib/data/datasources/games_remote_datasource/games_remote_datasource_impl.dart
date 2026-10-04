import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
import '../../models/response_model/games/game_model.dart';
import '../../models/response_model/games/game_invitations_response_model.dart';
import '../../models/response_model/games/game_members_response_model.dart';
import '../../models/response_model/games/booking_available_response_model.dart';
import '../../models/response_model/games/game_history_response_model.dart';
import '../../models/response_model/diwaniya/message_model.dart';
import '../../models/response_model/diwaniya/messages_response_model.dart';
import '../../models/request_model/games/create_game_request_model.dart';
import '../../models/request_model/games/join_game_request_model.dart';
import '../../models/request_model/games/update_game_booking_request_model.dart';
import '../../models/request_model/games/confirm_game_booking_request_model.dart';
import '../../models/request_model/games/rate_game_request_model.dart';
import '../../models/request_model/games/add_game_result_request_model.dart';
import '../../models/request_model/diwaniya/send_message_request_model.dart';
import '../../models/request_model/diwaniya/poll_vote_request_model.dart';
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'games_remote_datasource.dart';

@Injectable(as: GamesRemoteDataSource)
class GamesRemoteDataSourceImpl implements GamesRemoteDataSource {
  const GamesRemoteDataSourceImpl(this._apiCallHelper);
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
  Future<ApiResultModel<GameModel?>> createGame({required CreateGameRequestModel request}) async {
    try {
      final formDataMap = request.toFormData();
      final formData = FormData.fromMap(formDataMap);

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Games,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          // Normalize game data to handle user_permission as empty array in nested diwaniyas
          final gameData = _normalizeGameData(Map<String, dynamic>.from(response.data['data']));
          final result = GameModel.fromJson(gameData);
          return ApiResultModel<GameModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<GameInvitationsResponseModel?>> getGameInvitations() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: GamesInvitation,
      );
      return result.when(
        success: (Response response) async {
          // Normalize game data in invitations response
          final data = Map<String, dynamic>.from(response.data['data']);

          // Normalize receiving_games
          if (data['receiving_games'] is List) {
            final receivingGames = (data['receiving_games'] as List).map((game) {
              if (game is Map) {
                return _normalizeGameData(Map<String, dynamic>.from(game));
              }
              return game;
            }).toList();
            data['receiving_games'] = receivingGames;
          }

          // Normalize sending_games
          if (data['sending_games'] is List) {
            final sendingGames = (data['sending_games'] as List).map((game) {
              if (game is Map) {
                return _normalizeGameData(Map<String, dynamic>.from(game));
              }
              return game;
            }).toList();
            data['sending_games'] = sendingGames;
          }

          final result = GameInvitationsResponseModel.fromJson(data);
          return ApiResultModel<GameInvitationsResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameInvitationsResponseModel?>.failure(
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
  Future<ApiResultModel<GameModel?>> getGame({required int gameId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Games/$gameId',
      );
      return result.when(
        success: (Response response) async {
          // Normalize game data to handle user_permission as empty array in nested diwaniyas
          final gameData = _normalizeGameData(Map<String, dynamic>.from(response.data['data']));
          final result = GameModel.fromJson(gameData);
          return ApiResultModel<GameModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<String?>> acceptGame({required int gameId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/accept',
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
  Future<ApiResultModel<String?>> rejectGame({required int gameId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/reject',
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
  Future<ApiResultModel<String?>> joinGame({
    required int gameId,
    required JoinGameRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/join',
        formData: formData,
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
  Future<ApiResultModel<String?>> leaveGame({required int gameId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/leave',
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
  Future<ApiResultModel<String?>> changePosition({
    required int gameId,
    required String position,
    int? slotIndex,
  }) async {
    try {
      final map = <String, dynamic>{'position': position};
      if (slotIndex != null) map['slot_index'] = slotIndex.toString();
      final formData = FormData.fromMap(map);
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/change-position',
        formData: formData,
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
  Future<ApiResultModel<GameMembersResponseModel?>> getGameMembers({required int gameId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Games/$gameId/members',
      );
      return result.when(
        success: (Response response) async {
          final result = GameMembersResponseModel.fromJson(response.data['data']);
          return ApiResultModel<GameMembersResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameMembersResponseModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<GameMembersResponseModel?>> getGamePlayers({required int gameId}) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Games/$gameId/players',
      );
      return result.when(
        success: (Response response) async {
          final result = GameMembersResponseModel.fromJson(response.data['data']);
          return ApiResultModel<GameMembersResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameMembersResponseModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<String?>> deleteGameMember({
    required int gameId,
    required int userId,
  }) async {
    try {
      final formData = FormData.fromMap({'user_id': userId.toString()});
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/delete-member',
        formData: formData,
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
  Future<ApiResultModel<BookingAvailableResponseModel?>> checkBookingAvailable({
    required int gameId,
  }) async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/booking-available',
      );
      return result.when(
        success: (Response response) async {
          final result = BookingAvailableResponseModel.fromJson(response.data['data']);
          return ApiResultModel<BookingAvailableResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<BookingAvailableResponseModel?>.failure(
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
  Future<ApiResultModel<GameModel?>> updateGameBooking({
    required int gameId,
    required UpdateGameBookingRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/update-booking',
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          // Normalize game data to handle user_permission as empty array in nested diwaniyas
          final gameData = _normalizeGameData(Map<String, dynamic>.from(response.data['data']));
          final game = GameModel.fromJson(gameData);
          return ApiResultModel<GameModel?>.success(data: game);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<GameModel?>> confirmGameBooking({
    required int gameId,
    required ConfirmGameBookingRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/confirm-booking',
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          // Normalize game data to handle user_permission as empty array in nested diwaniyas
          final gameData = _normalizeGameData(Map<String, dynamic>.from(response.data['data']));
          final game = GameModel.fromJson(gameData);
          return ApiResultModel<GameModel?>.success(data: game);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<GameModel?>.failure(errorResultEntity: errorModel);
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
  Future<ApiResultModel<MessageModel?>> sendGameMessage({
    required int gameId,
    required SendMessageRequestModel request,
  }) async {
    try {
      final formDataMap = request.toFormData();
      FormData formData;

      if (request.type == 'image' || request.type == 'file') {
        // Handle file upload
        if (request.file != null) {
          final file = await MultipartFile.fromFile(
            request.file!.path,
            filename: request.file!.path.split('/').last,
          );
          // formDataMap[request.type] = file;
          formDataMap['content'] = file;
        }
        formData = FormData.fromMap(formDataMap);
      } else {
        formData = FormData.fromMap(formDataMap);
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/messages',
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
  Future<ApiResultModel<MessagesResponseModel?>> getGameMessages({
    required int gameId,
    int? page,
  }) async {
    try {
      final queryParams = page != null ? '?page=$page' : '';
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: '$Games/$gameId/messages$queryParams',
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
  Future<ApiResultModel<String?>> voteGamePoll({
    required int gameId,
    required PollVoteRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        // uri: '$Games/$gameId/poll-vote',
        uri: '/vote',
        formData: formData,
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
  Future<ApiResultModel<String?>> rateGame({
    required int gameId,
    required RateGameRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/rate',
        formData: formData,
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
  Future<ApiResultModel<String?>> addGameResult({
    required int gameId,
    required AddGameResultRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: '$Games/$gameId/result',
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data']?['message'] as String?;
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
  Future<ApiResultModel<GameHistoryResponseModel?>> getGameHistory({int? page}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) {
        queryParams['page'] = page;
      }

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: GameHistory,
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

  @override
  Future<ApiResultModel<List<GameModel>?>> getGamesResult() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: GamesResult,
      );
      return result.when(
        success: (Response response) async {
          final data = response.data['data'];

          // Handle direct array response
          if (data is List) {
            final games = data.map((game) {
              if (game is Map) {
                final normalized = _normalizeGameData(Map<String, dynamic>.from(game));
                return GameModel.fromJson(normalized);
              }
              return GameModel.fromJson(game as Map<String, dynamic>);
            }).toList();
            return ApiResultModel<List<GameModel>?>.success(data: games);
          }

          return ApiResultModel<List<GameModel>?>.success(data: []);
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

  @override
  Future<ApiResultModel<List<GameModel>?>> getActiveGames() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: ActiveGames,
      );
      return result.when(
        success: (Response response) async {
          final data = response.data['data'];

          // Handle direct array response
          if (data is List) {
            final games = data.map((game) {
              if (game is Map) {
                final normalized = _normalizeGameData(Map<String, dynamic>.from(game));
                return GameModel.fromJson(normalized);
              }
              return GameModel.fromJson(game as Map<String, dynamic>);
            }).toList();
            return ApiResultModel<List<GameModel>?>.success(data: games);
          }

          return ApiResultModel<List<GameModel>?>.failure(
            errorResultEntity: ErrorResultModel(message: 'Invalid response format'),
          );
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
