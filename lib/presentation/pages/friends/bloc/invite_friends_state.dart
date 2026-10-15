part of 'invite_friends_bloc.dart';

abstract class InviteFriendsState extends Equatable {
  const InviteFriendsState();

  @override
  List<Object?> get props => [];
}

class InviteFriendsInitial extends InviteFriendsState {}

class InviteFriendsLoading extends InviteFriendsState {}

class InviteFriendsLoaded extends InviteFriendsState {
  final date = DateTime.now();

  @override
  List<Object?> get props => [date];
}

class InviteFriendsSending extends InviteFriendsState {}

class InviteFriendsSent extends InviteFriendsState {
  final date = DateTime.now();

  @override
  List<Object?> get props => [date];
}

class InviteFriendsError extends InviteFriendsState {
  InviteFriendsError({required this.message, this.statusCode, this.loadFailed = false});

  final String message;
  final int? statusCode;
  final bool loadFailed;
  final date = DateTime.now();

  @override
  List<Object?> get props => [message, statusCode, loadFailed, date];
}
