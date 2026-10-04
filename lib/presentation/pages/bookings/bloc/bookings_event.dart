part of 'bookings_bloc.dart';

abstract class BookingsEvent extends Equatable {
  const BookingsEvent();

  @override
  List<Object?> get props => [];
}

class GetBookingsEvent extends BookingsEvent {}

class GetBookingDetailsEvent extends BookingsEvent {
  final int bookingId;
  
  const GetBookingDetailsEvent({required this.bookingId});
  
  @override
  List<Object?> get props => [bookingId];
}

class CreateBookingEvent extends BookingsEvent {
  final BookingRequestModel request;
  
  const CreateBookingEvent({required this.request});
  
  @override
  List<Object?> get props => [request];
}

class CheckVoucherEvent extends BookingsEvent {
  final VoucherRequestModel request;
  
  const CheckVoucherEvent({required this.request});
  
  @override
  List<Object?> get props => [request];
}

