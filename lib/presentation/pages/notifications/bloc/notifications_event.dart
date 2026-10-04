part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
}

class GetNotificationsEvent extends NotificationsEvent {
  const GetNotificationsEvent( {this.model,this.more = false});
  final NotificationsRequestModel? model;
  final bool more;
  @override
  List<Object?> get props => [];
}

class MarkAllAsReadEvent extends NotificationsEvent {
  @override
  List<Object?> get props => [];
}

class GetUnreadCountEvent extends NotificationsEvent {
  @override
  List<Object?> get props => [];
}

class ClearNotificationsEvent extends NotificationsEvent {
  @override
  List<Object?> get props => [];
}

class MarkNotificationReadEvent extends NotificationsEvent {
  const MarkNotificationReadEvent(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
