part of 'games_bloc.dart';

abstract class GamesState extends Equatable {
  const GamesState();

  @override
  List<Object?> get props => [];
}

class GamesInitial extends GamesState {}

class GamesLoading extends GamesState {
  final DateTime date = DateTime.now();
  GamesLoading();
  @override
  List<Object?> get props => [date];
}

class GetGameLoading extends GamesState {}

class JoinGameSuccess extends GamesState {}

class LeaveGameSuccess extends GamesState {}

class ChangePositionSuccess extends GamesState {}

class AcceptGameSuccess extends GamesState {
  final String message;
  const AcceptGameSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AddGameResultSuccess extends GamesState {
  final String message;
  const AddGameResultSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class GamesSuccess extends GamesState {
  final date = DateTime.now();
  final bool scrollToBottom;
  GamesSuccess({this.scrollToBottom = false});

  @override
  List<Object?> get props => [date, scrollToBottom];
}

class DeleteGameMemberSuccess extends GamesState {
  final date = DateTime.now();
  @override
  List<Object?> get props => [date];
}

class CheckBookingAvailableSuccess extends GamesState {
  final BookingAvailableResponseModel data;
  const CheckBookingAvailableSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class GamesResultLoaded extends GamesState {
  final List<GameModel> games;

  const GamesResultLoaded(this.games);

  @override
  List<Object?> get props => [games];
}

class GamesError extends GamesState {
  final String message;
  const GamesError({required this.message});

  @override
  List<Object?> get props => [message];
}
