import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
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

abstract class GamesRemoteDataSource {
  Future<ApiResultModel<GameModel?>> createGame({required CreateGameRequestModel request});

  Future<ApiResultModel<GameInvitationsResponseModel?>> getGameInvitations();

  Future<ApiResultModel<GameModel?>> getGame({required int gameId});

  Future<ApiResultModel<String?>> acceptGame({required int gameId});

  Future<ApiResultModel<String?>> rejectGame({required int gameId});

  Future<ApiResultModel<String?>> joinGame({
    required int gameId,
    required JoinGameRequestModel request,
  });

  Future<ApiResultModel<String?>> leaveGame({required int gameId});

  Future<ApiResultModel<String?>> changePosition({
    required int gameId,
    required String position,
    int? slotIndex,
  });

  Future<ApiResultModel<GameMembersResponseModel?>> getGameMembers({required int gameId});

  Future<ApiResultModel<GameMembersResponseModel?>> getGamePlayers({required int gameId});

  Future<ApiResultModel<String?>> deleteGameMember({required int gameId, required int userId});

  Future<ApiResultModel<BookingAvailableResponseModel?>> checkBookingAvailable({
    required int gameId,
  });

  Future<ApiResultModel<GameModel?>> updateGameBooking({
    required int gameId,
    required UpdateGameBookingRequestModel request,
  });

  Future<ApiResultModel<GameModel?>> confirmGameBooking({
    required int gameId,
    required ConfirmGameBookingRequestModel request,
  });

  Future<ApiResultModel<MessageModel?>> sendGameMessage({
    required int gameId,
    required SendMessageRequestModel request,
  });

  Future<ApiResultModel<MessagesResponseModel?>> getGameMessages({
    required int gameId,
    int? page,
  });

  Future<ApiResultModel<String?>> voteGamePoll({
    required int gameId,
    required PollVoteRequestModel request,
  });

  Future<ApiResultModel<String?>> rateGame({
    required int gameId,
    required RateGameRequestModel request,
  });

  Future<ApiResultModel<String?>> addGameResult({
    required int gameId,
    required AddGameResultRequestModel request,
  });

  Future<ApiResultModel<GameHistoryResponseModel?>> getGameHistory({int? page});

  Future<ApiResultModel<List<GameModel>?>> getGamesResult();

  Future<ApiResultModel<List<GameModel>?>> getActiveGames();
}
