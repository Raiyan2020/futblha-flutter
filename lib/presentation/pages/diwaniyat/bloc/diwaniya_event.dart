part of 'diwaniya_bloc.dart';

abstract class DiwaniyaEvent extends Equatable {
  const DiwaniyaEvent();

  @override
  List<Object?> get props => [];
}

class GetDiwaniyaTypesEvent extends DiwaniyaEvent {}

class GetDiwaniyaEvent extends DiwaniyaEvent {
  final int diwaniyaId;

  const GetDiwaniyaEvent({required this.diwaniyaId});

  @override
  List<Object?> get props => [diwaniyaId];
}

class CreateDiwaniyaEvent extends DiwaniyaEvent {
  final CreateDiwaniyaRequestModel request;

  const CreateDiwaniyaEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class UpdateDiwaniyaEvent extends DiwaniyaEvent {
  final int diwaniyaId;
  final CreateDiwaniyaRequestModel request;

  const UpdateDiwaniyaEvent({required this.diwaniyaId, required this.request});

  @override
  List<Object?> get props => [diwaniyaId, request];
}

class GetOtherDiwaniyasEvent extends DiwaniyaEvent {}

class GetDiwaniyasOverviewEvent extends DiwaniyaEvent {
  final String? type;
  final int? membersCount;
  final int? rating;
  final String? name;
  final int? page;
  final int? perPage;
  final bool loadMore; // If true, append items instead of replacing

  const GetDiwaniyasOverviewEvent({
    this.type,
    this.membersCount,
    this.rating,
    this.name,
    this.page,
    this.perPage,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [type, membersCount, rating, name, page, perPage, loadMore];
}

class GetDiwaniyaMembersEvent extends DiwaniyaEvent {
  final int diwaniyaId;

  const GetDiwaniyaMembersEvent({required this.diwaniyaId});

  @override
  List<Object?> get props => [diwaniyaId];
}

class GetJoinRequestsEvent extends DiwaniyaEvent {
  final int diwaniyaId;

  const GetJoinRequestsEvent({required this.diwaniyaId});

  @override
  List<Object?> get props => [diwaniyaId];
}

class JoinDiwaniyaEvent extends DiwaniyaEvent {
  final int diwaniyaId;

  const JoinDiwaniyaEvent({required this.diwaniyaId});

  @override
  List<Object?> get props => [diwaniyaId];
}

class LeaveDiwaniyaEvent extends DiwaniyaEvent {
  final int diwaniyaId;

  const LeaveDiwaniyaEvent({required this.diwaniyaId});

  @override
  List<Object?> get props => [diwaniyaId];
}

class DeleteDiwaniyaEvent extends DiwaniyaEvent {
  final int diwaniyaId;

  const DeleteDiwaniyaEvent({required this.diwaniyaId});

  @override
  List<Object?> get props => [diwaniyaId];
}

class ApproveJoinRequestEvent extends DiwaniyaEvent {
  final int diwaniyaId;
  final int userId;

  const ApproveJoinRequestEvent({required this.diwaniyaId, required this.userId});

  @override
  List<Object?> get props => [diwaniyaId, userId];
}

class RemoveMemberEvent extends DiwaniyaEvent {
  final int diwaniyaId;
  final int userId;

  const RemoveMemberEvent({required this.diwaniyaId, required this.userId});

  @override
  List<Object?> get props => [diwaniyaId, userId];
}

class SendMessageEvent extends DiwaniyaEvent {
  final int diwaniyaId;
  final SendMessageRequestModel request;

  const SendMessageEvent({required this.diwaniyaId, required this.request});

  @override
  List<Object?> get props => [diwaniyaId, request];
}

class GetMessagesEvent extends DiwaniyaEvent {
  final int diwaniyaId;
  final bool scrollToBottom;
  /// Page number for pagination. 1 or null = first page (replace messages). >1 = load more (append).
  final int? page;

  const GetMessagesEvent({
    required this.diwaniyaId,
    this.scrollToBottom = false,
    this.page,
  });

  @override
  List<Object?> get props => [diwaniyaId, scrollToBottom, page];
}

class VotePollEvent extends DiwaniyaEvent {
  final int diwaniyaId;
  final PollVoteRequestModel request;

  const VotePollEvent({required this.diwaniyaId, required this.request});

  @override
  List<Object?> get props => [diwaniyaId, request];
}

class GetDiwaniyaRankingEvent extends DiwaniyaEvent {
  final String? date; // "year" or "month"

  const GetDiwaniyaRankingEvent({this.date});

  @override
  List<Object?> get props => [date];
}

class GetDiwaniyaGamesEvent extends DiwaniyaEvent {
  final int diwaniyaId;
  final int? page;

  const GetDiwaniyaGamesEvent({required this.diwaniyaId, this.page});

  @override
  List<Object?> get props => [diwaniyaId, page];
}

class MessageReceivedEvent extends DiwaniyaEvent {
  final MessageModel message;

  const MessageReceivedEvent({required this.message});

  @override
  List<Object?> get props => [message];
}
