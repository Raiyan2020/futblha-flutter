part of 'bookings_bloc.dart';

abstract class BookingsState extends Equatable {
  const BookingsState();

  @override
  List<Object?> get props => [];
}

class BookingsInitial extends BookingsState {}

class BookingsLoading extends BookingsState {}

class BookingsSuccess extends BookingsState {}

class BookingsError extends BookingsState {
  final String message;
  const BookingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

