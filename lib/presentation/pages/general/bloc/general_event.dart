part of 'general_bloc.dart';

abstract class GeneralEvent extends Equatable {
  const GeneralEvent();

  @override
  List<Object?> get props => [];
}

class GetCountriesEvent extends GeneralEvent {}

class GetCitiesEvent extends GeneralEvent {}

class GetPositionsEvent extends GeneralEvent {}

class GetHomeEvent extends GeneralEvent {}

class GetUpcomingGamesEvent extends GeneralEvent {}
