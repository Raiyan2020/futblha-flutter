part of 'playgrounds_bloc.dart';

abstract class PlaygroundsState extends Equatable {
  const PlaygroundsState();

  @override
  List<Object?> get props => [];
}

class PlaygroundsInitial extends PlaygroundsState {}

class PlaygroundsLoading extends PlaygroundsState {}

class PlaygroundsSuccess extends PlaygroundsState {
  final date = DateTime.now();

  @override
  List<Object?> get props => [date];
}

class PlaygroundsError extends PlaygroundsState {
  final String message;
  const PlaygroundsError({required this.message});

  @override
  List<Object?> get props => [message];
}
