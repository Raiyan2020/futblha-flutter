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
  // HTTP status of the failed request, when known (e.g. 409 for a booking conflict).
  final int? statusCode;
  const BookingsError({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

