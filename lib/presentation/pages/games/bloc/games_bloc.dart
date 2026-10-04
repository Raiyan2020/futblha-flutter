import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../data/datasources/games_remote_datasource/games_remote_datasource.dart';
import '../../notifications/bloc/notifications_bloc.dart';
import '../../../../data/models/response_model/games/game_model.dart';
import '../../../../data/models/response_model/games/game_invitations_response_model.dart';
import '../../../../data/models/response_model/games/game_members_response_model.dart';
import '../../../../data/models/response_model/games/game_history_response_model.dart';
import '../../../../data/models/response_model/diwaniya/paginate_model.dart';
import '../../../../data/models/request_model/games/create_game_request_model.dart';
import '../../../../data/models/request_model/games/join_game_request_model.dart';
import '../../../../data/models/request_model/games/update_game_booking_request_model.dart';
import '../../../../data/models/request_model/games/confirm_game_booking_request_model.dart';
import '../../../../data/models/request_model/games/rate_game_request_model.dart';
import '../../../../data/models/request_model/games/add_game_result_request_model.dart';
import '../../../../data/models/request_model/diwaniya/send_message_request_model.dart';
import '../../../../data/models/request_model/diwaniya/poll_vote_request_model.dart';
import '../../../../data/models/response_model/games/booking_available_response_model.dart';
import '../../../../data/models/response_model/diwaniya/message_model.dart';
import '../../../../data/models/response_model/diwaniya/messages_response_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';

part 'games_event.dart';
part 'games_state.dart';

@injectable
class GamesBloc extends Bloc<GamesEvent, GamesState> {
  final GamesRemoteDataSource _remoteDataSource;

  // Data stored in bloc
  GameModel? createdGame;
  GameInvitationsResponseModel? gameInvitations;
  GameModel? gameDetails;
  GameMembersResponseModel? gameMembers;
  BookingAvailableResponseModel? bookingAvailable;
  MessagesResponseModel? gameMessages;
  bool gameMessagesLoadingMore = false;
  List<GameModel> gameHistory = [];
  PaginateModel? gameHistoryPagination;
  bool gameHistoryReachedMax = false;
  List<GameModel> activeGames = [];
  List<GameModel> gamesNeedingResult = [];

  GamesBloc(this._remoteDataSource) : super(GamesInitial()) {
    on<CreateGameEvent>(_createGame);
    on<GetGameInvitationsEvent>(_getGameInvitations);
    on<GetGameEvent>(_getGame);
    on<AcceptGameEvent>(_acceptGame);
    on<RejectGameEvent>(_rejectGame);
    on<JoinGameEvent>(_joinGame);
    on<LeaveGameEvent>(_leaveGame);
    on<ChangePositionEvent>(_changePosition);
    on<GetGameMembersEvent>(_getGameMembers);
    on<DeleteGameMemberEvent>(_deleteGameMember);
    on<CheckBookingAvailableEvent>(_checkBookingAvailable);
    on<UpdateGameBookingEvent>(_updateGameBooking);
    on<ConfirmGameBookingEvent>(_confirmGameBooking);
    on<SendGameMessageEvent>(_sendGameMessage);
    on<GetGameMessagesEvent>(_getGameMessages);
    on<VoteGamePollEvent>(_voteGamePoll);
    on<RateGameEvent>(_rateGame);
    on<AddGameResultEvent>(_addGameResult);
    on<GetGameHistoryEvent>(_getGameHistory);
    on<GetGamesResultEvent>(_getGamesResult);
    on<GetActiveGamesEvent>(_getActiveGames);
    on<GameMessageReceivedEvent>(_gameMessageReceived);
  }

  Future<void> _createGame(CreateGameEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<GameModel?> result = await _remoteDataSource.createGame(
      request: event.request,
    );
    result.when(
      success: (data) {
        if (data != null) {
          createdGame = data;
          emit(GamesSuccess());
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getGameInvitations(GetGameInvitationsEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<GameInvitationsResponseModel?> result = await _remoteDataSource
        .getGameInvitations();
    result.when(
      success: (data) {
        if (data != null) {
          gameInvitations = data;
          emit(GamesSuccess());
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getGame(GetGameEvent event, Emitter<GamesState> emit) async {
    if (event.hardLoading == true) {
      emit(GetGameLoading());
    } else {
      emit(GamesLoading());
    }
    final ApiResultModel<GameModel?> result = await _remoteDataSource.getGame(gameId: event.gameId);
    result.when(
      success: (data) {
        if (data != null) {
          gameDetails = data;
          add(GetGameMembersEvent(gameId: data.id!, hardLoading: event.hardLoading));
          emit(GamesSuccess());
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _acceptGame(AcceptGameEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.acceptGame(gameId: event.gameId);
    result.when(
      success: (data) {
        // Refresh game invitations after acceptance
        add(GetGameInvitationsEvent());
        // The backend clears the invitation badge for every member.
        locator<NotificationsBloc>().add(GetUnreadCountEvent());
        emit(AcceptGameSuccess(data ?? LocaleKeys.success));
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _rejectGame(RejectGameEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.rejectGame(gameId: event.gameId);
    result.when(
      success: (data) {
        // Refresh game invitations after rejection
        add(GetGameInvitationsEvent());
        // The backend clears the invitation badge for every member.
        locator<NotificationsBloc>().add(GetUnreadCountEvent());
        emit(GamesSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _joinGame(JoinGameEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.joinGame(
      gameId: event.gameId,
      request: event.request,
    );
    result.when(
      success: (data) {
        emit(JoinGameSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _leaveGame(LeaveGameEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.leaveGame(gameId: event.gameId);
    result.when(
      success: (data) {
        emit(LeaveGameSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _changePosition(ChangePositionEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.changePosition(
      gameId: event.gameId,
      position: event.position,
      slotIndex: event.slotIndex,
    );
    result.when(
      success: (data) {
        add(GetGameEvent(gameId: event.gameId));
        add(GetGameMembersEvent(gameId: event.gameId));
        emit(ChangePositionSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getGameMembers(GetGameMembersEvent event, Emitter<GamesState> emit) async {
    if (event.hardLoading == true) {
      emit(GetGameLoading());
    } else {
      emit(GamesLoading());
    }

    // Check if user is a member - use /members endpoint for members, /players for non-members
    final isMember = gameDetails?.userPermission?.isMember == true;

    final ApiResultModel<GameMembersResponseModel?> result = isMember
        ? await _remoteDataSource.getGameMembers(gameId: event.gameId)
        : await _remoteDataSource.getGamePlayers(gameId: event.gameId);

    result.when(
      success: (data) {
        if (data != null) {
          gameMembers = data;
          emit(GamesSuccess());
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _deleteGameMember(DeleteGameMemberEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.deleteGameMember(
      gameId: event.gameId,
      userId: event.userId,
    );
    result.when(
      success: (data) {
        // Refresh game members after deletion
        add(GetGameMembersEvent(gameId: event.gameId));
        emit(DeleteGameMemberSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _checkBookingAvailable(
    CheckBookingAvailableEvent event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesLoading());
    final ApiResultModel<BookingAvailableResponseModel?> result = await _remoteDataSource
        .checkBookingAvailable(gameId: event.gameId);
    result.when(
      success: (data) {
        if (data != null) {
          bookingAvailable = data;
          emit(CheckBookingAvailableSuccess(data));
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _updateGameBooking(UpdateGameBookingEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<GameModel?> result = await _remoteDataSource.updateGameBooking(
      gameId: event.gameId,
      request: event.request,
    );
    result.when(
      success: (data) {
        // Update game details with the returned game data
        if (data != null) {
          gameDetails = data;
        } else if (gameDetails?.id != null) {
          // Fallback: refresh game details if data is null
          add(GetGameEvent(gameId: gameDetails!.id!));
        }
        emit(GamesSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _confirmGameBooking(ConfirmGameBookingEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<GameModel?> result = await _remoteDataSource.confirmGameBooking(
      gameId: event.gameId,
      request: event.request,
    );
    result.when(
      success: (data) {
        // Update game details with the returned game data
        if (data != null) {
          gameDetails = data;
        } else if (gameDetails?.id != null) {
          // Fallback: refresh game details if data is null
          add(GetGameEvent(gameId: gameDetails!.id!));
        }
        emit(GamesSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _sendGameMessage(SendGameMessageEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<MessageModel?> result = await _remoteDataSource.sendGameMessage(
      gameId: event.gameId,
      request: event.request,
    );
    result.when(
      success: (data) {
        // Refresh messages after sending
        add(GetGameMessagesEvent(gameId: event.gameId, scrollToBottom: true));
        emit(GamesSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getGameMessages(GetGameMessagesEvent event, Emitter<GamesState> emit) async {
    final isLoadMore = event.page != null && event.page! > 1;
    if (isLoadMore) {
      gameMessagesLoadingMore = true;
    } else {
      emit(GamesLoading());
    }
    final ApiResultModel<MessagesResponseModel?> result = await _remoteDataSource.getGameMessages(
      gameId: event.gameId,
      page: event.page,
    );
    if (isLoadMore) {
      gameMessagesLoadingMore = false;
    }
    result.when(
      success: (data) {
        if (data != null) {
          if (isLoadMore && gameMessages?.items != null && data.items != null) {
            gameMessages = MessagesResponseModel(
              items: [...gameMessages!.items!, ...data.items!],
              paginate: data.paginate,
              extra: data.extra,
            );
          } else {
            gameMessages = data;
          }
          emit(GamesSuccess(scrollToBottom: event.scrollToBottom));
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _voteGamePoll(VoteGamePollEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.voteGamePoll(
      gameId: event.gameId,
      request: event.request,
    );
    result.when(
      success: (data) {
        // Refresh messages after voting
        add(GetGameMessagesEvent(gameId: event.gameId));
        emit(GamesSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _rateGame(RateGameEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.rateGame(
      gameId: event.gameId,
      request: event.request,
    );
    result.when(
      success: (data) {
        emit(GamesSuccess());
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _addGameResult(AddGameResultEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<String?> result = await _remoteDataSource.addGameResult(
      gameId: event.gameId,
      request: event.request,
    );
    result.when(
      success: (data) {
        emit(AddGameResultSuccess(data ?? ''));
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getGameHistory(GetGameHistoryEvent event, Emitter<GamesState> emit) async {
    // Reset on first page
    if (event.page == null || event.page == 1) {
      gameHistory = [];
      gameHistoryReachedMax = false;
      gameHistoryPagination = null;
      emit(GamesLoading());
    }

    final ApiResultModel<GameHistoryResponseModel?> result = await _remoteDataSource.getGameHistory(
      page: event.page,
    );
    result.when(
      success: (data) {
        if (data != null) {
          if (data.items != null && data.items!.isNotEmpty) {
            if (event.page == null || event.page == 1) {
              gameHistory = data.items!;
            } else {
              gameHistory.addAll(data.items!);
            }
            gameHistoryPagination = data.paginate;

            // Determine if we've reached the max
            if (data.paginate != null) {
              // Use pagination metadata
              final currentPage = data.paginate!.currentPage ?? 1;
              final totalPages = data.paginate!.totalPages ?? 1;
              gameHistoryReachedMax = currentPage >= totalPages;
            } else {
              // No pagination metadata - check if we got fewer items than expected
              // If we got a full page (assuming 10-20 items per page), continue
              // Otherwise, we've reached the end
              final itemsCount = data.items!.length;
              gameHistoryReachedMax = itemsCount < 10; // Assuming 10+ items means more pages
            }
          } else {
            // Empty response means we've reached the end
            gameHistoryReachedMax = true;
          }
          emit(GamesSuccess());
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getGamesResult(GetGamesResultEvent event, Emitter<GamesState> emit) async {
    final ApiResultModel<List<GameModel>?> result = await _remoteDataSource.getGamesResult();
    result.when(
      success: (data) {
        gamesNeedingResult = data ?? [];
        emit(GamesResultLoaded(gamesNeedingResult));
      },
      failure: (error) {
        gamesNeedingResult = [];
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getActiveGames(GetActiveGamesEvent event, Emitter<GamesState> emit) async {
    emit(GamesLoading());
    final ApiResultModel<List<GameModel>?> result = await _remoteDataSource.getActiveGames();
    result.when(
      success: (data) {
        if (data != null) {
          activeGames = data;
          emit(GamesSuccess());
        } else {
          emit(const GamesError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GamesError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _gameMessageReceived(
    GameMessageReceivedEvent event,
    Emitter<GamesState> emit,
  ) async {
    // Add message to gameMessages list if it doesn't already exist
    // The duplicate check by ID prevents duplicates regardless of whether it comes from API or Pusher
    if (gameMessages?.items != null) {
      // Check if message already exists (avoid duplicates)
      final messageExists = gameMessages!.items!.any((msg) => msg.id == event.message.id);

      if (!messageExists) {
        // Message doesn't exist, add it
        gameMessages!.items!.insert(0, event.message);
        emit(GamesSuccess());
      }
    } else {
      // Initialize gameMessages list with the new message
      gameMessages = MessagesResponseModel(items: [event.message]);
      emit(GamesSuccess());
    }
  }
}
