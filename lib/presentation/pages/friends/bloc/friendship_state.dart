part of 'friendship_bloc.dart';

enum FriendshipAction { send, accept, reject }

abstract class FriendshipState extends Equatable {
  const FriendshipState();

  @override
  List<Object?> get props => [];
}

class FriendshipInitial extends FriendshipState {}

class FriendshipLoading extends FriendshipState {}

class FriendshipLoaded extends FriendshipState {
  final date = DateTime.now();

  @override
  List<Object?> get props => [date];
}

class FriendshipActionInProgress extends FriendshipState {
  const FriendshipActionInProgress(this.action);
  final FriendshipAction action;

  @override
  List<Object?> get props => [action];
}

class FriendshipActionSuccess extends FriendshipState {
  FriendshipActionSuccess(this.action);
  final FriendshipAction action;
  final date = DateTime.now();

  @override
  List<Object?> get props => [action, date];
}

class FriendshipError extends FriendshipState {
  FriendshipError({required this.message, this.statusCode, this.action, this.loadFailed = false});

  final String message;
  final int? statusCode;
  final FriendshipAction? action;
  // The status itself couldn't be loaded (show retry instead of actions).
  final bool loadFailed;
  final date = DateTime.now();

  @override
  List<Object?> get props => [message, statusCode, action, loadFailed, date];
}
