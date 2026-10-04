part of 'general_bloc.dart';

abstract class GeneralState extends Equatable {
  const GeneralState();

  @override
  List<Object?> get props => [];
}

class GeneralInitial extends GeneralState {}

class GeneralLoading extends GeneralState {}

class GeneralSuccess extends GeneralState {}

class GeneralError extends GeneralState {
  final String message;
  const GeneralError({required this.message});

  @override
  List<Object?> get props => [message];
}

