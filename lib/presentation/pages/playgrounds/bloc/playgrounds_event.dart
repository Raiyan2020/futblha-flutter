part of 'playgrounds_bloc.dart';

abstract class PlaygroundsEvent extends Equatable {
  const PlaygroundsEvent();

  @override
  List<Object?> get props => [];
}

class GetLandTypesEvent extends PlaygroundsEvent {}

class GetFacilitiesEvent extends PlaygroundsEvent {}

class GetCapacitiesEvent extends PlaygroundsEvent {}

class GetPlaygroundsEvent extends PlaygroundsEvent {
  final PlaygroundFilterRequestModel? filters;

  const GetPlaygroundsEvent({this.filters});

  @override
  List<Object?> get props => [filters];
}

class GetPlaygroundDetailsEvent extends PlaygroundsEvent {
  final int playgroundId;
  final String? date;

  const GetPlaygroundDetailsEvent({required this.playgroundId, this.date});

  @override
  List<Object?> get props => [playgroundId, date];
}

class AddRateEvent extends PlaygroundsEvent {
  final int playgroundId;
  final int rate;

  const AddRateEvent({required this.playgroundId, required this.rate});

  @override
  List<Object?> get props => [playgroundId, rate];
}
