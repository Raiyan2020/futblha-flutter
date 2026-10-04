part of 'games_bloc.dart';

abstract class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object?> get props => [];
}

class CreateGameEvent extends GamesEvent {
  final CreateGameRequestModel request;

  const CreateGameEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class GetGameInvitationsEvent extends GamesEvent {}

class GetGameEvent extends GamesEvent {
  final int gameId;
  final bool hardLoading;

  const GetGameEvent({required this.gameId, this.hardLoading = false});

  @override
  List<Object?> get props => [gameId];
}

class AcceptGameEvent extends GamesEvent {
  final int gameId;

  const AcceptGameEvent({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class RejectGameEvent extends GamesEvent {
  final int gameId;

  const RejectGameEvent({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class JoinGameEvent extends GamesEvent {
  final int gameId;
  final JoinGameRequestModel request;

  const JoinGameEvent({required this.gameId, required this.request});

  @override
  List<Object?> get props => [gameId, request];
}

class LeaveGameEvent extends GamesEvent {
  final int gameId;

  const LeaveGameEvent({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class ChangePositionEvent extends GamesEvent {
  final int gameId;
  final String position;
  final int? slotIndex;

  const ChangePositionEvent({required this.gameId, required this.position, this.slotIndex});

  @override
  List<Object?> get props => [gameId, position, slotIndex];
}

class GetGameMembersEvent extends GamesEvent {
  final int gameId;
  final bool hardLoading;

  const GetGameMembersEvent({required this.gameId, this.hardLoading = false});

  @override
  List<Object?> get props => [gameId];
}

class DeleteGameMemberEvent extends GamesEvent {
  final int gameId;
  final int userId;

  const DeleteGameMemberEvent({required this.gameId, required this.userId});

  @override
  List<Object?> get props => [gameId, userId];
}

class CheckBookingAvailableEvent extends GamesEvent {
  final int gameId;

  const CheckBookingAvailableEvent({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class UpdateGameBookingEvent extends GamesEvent {
  final int gameId;
  final UpdateGameBookingRequestModel request;

  const UpdateGameBookingEvent({required this.gameId, required this.request});

  @override
  List<Object?> get props => [gameId, request];
}

class ConfirmGameBookingEvent extends GamesEvent {
  final int gameId;
  final ConfirmGameBookingRequestModel request;

  const ConfirmGameBookingEvent({required this.gameId, required this.request});

  @override
  List<Object?> get props => [gameId, request];
}

class SendGameMessageEvent extends GamesEvent {
  final int gameId;
  final SendMessageRequestModel request;

  const SendGameMessageEvent({required this.gameId, required this.request});

  @override
  List<Object?> get props => [gameId, request];
}

class GetGameMessagesEvent extends GamesEvent {
  final int gameId;
  final bool scrollToBottom;
  /// Page number for pagination. 1 or null = first page (replace messages). >1 = load more (append).
  final int? page;

  const GetGameMessagesEvent({
    required this.gameId,
    this.scrollToBottom = false,
    this.page,
  });

  @override
  List<Object?> get props => [gameId, scrollToBottom, page];
}

class VoteGamePollEvent extends GamesEvent {
  final int gameId;
  final PollVoteRequestModel request;

  const VoteGamePollEvent({required this.gameId, required this.request});

  @override
  List<Object?> get props => [gameId, request];
}

class RateGameEvent extends GamesEvent {
  final int gameId;
  final RateGameRequestModel request;

  const RateGameEvent({required this.gameId, required this.request});

  @override
  List<Object?> get props => [gameId, request];
}

class AddGameResultEvent extends GamesEvent {
  final int gameId;
  final AddGameResultRequestModel request;

  const AddGameResultEvent({required this.gameId, required this.request});

  @override
  List<Object?> get props => [gameId, request];
}

class GetGameHistoryEvent extends GamesEvent {
  final int? page;

  const GetGameHistoryEvent({this.page});

  @override
  List<Object?> get props => [page];
}

class GetGamesResultEvent extends GamesEvent {
  const GetGamesResultEvent();
}

class GetActiveGamesEvent extends GamesEvent {
  const GetActiveGamesEvent();
}

class GameMessageReceivedEvent extends GamesEvent {
  final MessageModel message;

  const GameMessageReceivedEvent({required this.message});

  @override
  List<Object?> get props => [message];
}
