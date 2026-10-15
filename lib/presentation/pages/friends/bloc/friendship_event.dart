part of 'friendship_bloc.dart';

abstract class FriendshipEvent extends Equatable {
  const FriendshipEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriendshipEvent extends FriendshipEvent {
  const LoadFriendshipEvent({required this.userId});
  final int userId;

  @override
  List<Object?> get props => [userId];
}

class SendFriendRequestEvent extends FriendshipEvent {
  const SendFriendRequestEvent({required this.userId});
  final int userId;

  @override
  List<Object?> get props => [userId];
}

/// [userId] (the sender) is used to reload the real state after a 409.
class AcceptFriendRequestEvent extends FriendshipEvent {
  const AcceptFriendRequestEvent({required this.requestId, this.userId});
  final int requestId;
  final int? userId;

  @override
  List<Object?> get props => [requestId, userId];
}

class RejectFriendRequestEvent extends FriendshipEvent {
  const RejectFriendRequestEvent({required this.requestId, this.userId});
  final int requestId;
  final int? userId;

  @override
  List<Object?> get props => [requestId, userId];
}
