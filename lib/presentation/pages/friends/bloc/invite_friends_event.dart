part of 'invite_friends_bloc.dart';

abstract class InviteFriendsEvent extends Equatable {
  const InviteFriendsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvitableFriendsEvent extends InviteFriendsEvent {
  const LoadInvitableFriendsEvent({required this.gameId});
  final int gameId;

  @override
  List<Object?> get props => [gameId];
}

class SendInvitationsEvent extends InviteFriendsEvent {
  const SendInvitationsEvent({required this.gameId, required this.userIds});
  final int gameId;
  final List<int> userIds;

  @override
  List<Object?> get props => [gameId, userIds];
}
