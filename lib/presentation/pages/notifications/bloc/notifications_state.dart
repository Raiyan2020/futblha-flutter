part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
}

class NotificationsInitial extends NotificationsState {
  @override
  List<Object> get props => [];
}

class GetNotificationsSuccess extends NotificationsState {
  final date = DateTime.now();
  @override
  List<Object?> get props => [date];
}

class GetNotificationsLoading extends NotificationsState {
  @override
  List<Object?> get props => [];
}

class ReadNotificationsSuccess extends NotificationsState {
  @override
  List<Object?> get props => [];
}

class ReadNotificationsLoading extends NotificationsState {
  @override
  List<Object?> get props => [];
}

class NotificationsErrorState extends NotificationsState {
  const NotificationsErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [];
}

class GetUnreadCountLoading extends NotificationsState {
  @override
  List<Object?> get props => [];
}

class GetUnreadCountSuccess extends NotificationsState {
  @override
  List<Object?> get props => [];
}

class ClearNotificationsLoading extends NotificationsState {
  @override
  List<Object?> get props => [];
}

class ClearNotificationsSuccess extends NotificationsState {
  @override
  List<Object?> get props => [];
}
