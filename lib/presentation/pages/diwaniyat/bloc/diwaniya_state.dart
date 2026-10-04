part of 'diwaniya_bloc.dart';

abstract class DiwaniyaState extends Equatable {
  const DiwaniyaState();

  @override
  List<Object?> get props => [];
}

class DiwaniyaInitial extends DiwaniyaState {}

class DiwaniyaLoading extends DiwaniyaState {}

class UpdateDiwaniyaSuccess extends DiwaniyaState {}

class DiwaniyaMembersLoading extends DiwaniyaState {}

class DiwaniyaSuccess extends DiwaniyaState {
  final bool scrollToBottom;
  final DateTime time = DateTime.now();
  DiwaniyaSuccess({this.scrollToBottom = false});

  @override
  List<Object?> get props => [time];
}

class JoinDiwaniyaSuccess extends DiwaniyaState {
  final String message;
  const JoinDiwaniyaSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class LeaveDiwaniyaSuccess extends DiwaniyaState {
  final String message;
  const LeaveDiwaniyaSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class DeleteDiwaniyaSuccess extends DiwaniyaState {
  final String message;
  const DeleteDiwaniyaSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ApproveJoinRequestSuccess extends DiwaniyaState {
  final String message;
  const ApproveJoinRequestSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class DiwaniyaError extends DiwaniyaState {
  final String message;
  const DiwaniyaError({required this.message});

  @override
  List<Object?> get props => [message];
}
