import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../data/datasources/playgrounds_remote_datasource/playgrounds_remote_datasource.dart';
import '../../../../data/models/response_model/playgrounds/booking_model.dart';
import '../../../../data/models/response_model/playgrounds/booking_response_model.dart';
import '../../../../data/models/response_model/playgrounds/bookings_list_response_model.dart';
import '../../../../data/models/response_model/playgrounds/voucher_response_model.dart';
import '../../../../data/models/request_model/playgrounds/booking_request_model.dart';
import '../../../../data/models/request_model/playgrounds/voucher_request_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';

part 'bookings_event.dart';
part 'bookings_state.dart';

@injectable
class BookingsBloc extends Bloc<BookingsEvent, BookingsState> {
  final PlaygroundsRemoteDataSource _remoteDataSource;

  // Data stored in bloc
  List<BookingModel> bookings = [];
  BookingModel? bookingDetails;
  VoucherResponseModel? voucherDetails;

  BookingsBloc(this._remoteDataSource) : super(BookingsInitial()) {
    on<GetBookingsEvent>(_getBookings);
    on<GetBookingDetailsEvent>(_getBookingDetails);
    on<CreateBookingEvent>(_createBooking);
    on<CheckVoucherEvent>(_checkVoucher);
  }

  Future<void> _getBookings(GetBookingsEvent event, Emitter<BookingsState> emit) async {
    emit(BookingsLoading());
    final ApiResultModel<BookingsListResponseModel?> result = await _remoteDataSource.getBookings();
    result.when(
      success: (data) {
        if (data != null) {
          bookings = data.data ?? [];
          emit(BookingsSuccess());
        } else {
          emit(const BookingsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(BookingsError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getBookingDetails(GetBookingDetailsEvent event, Emitter<BookingsState> emit) async {
    emit(BookingsLoading());
    final ApiResultModel<BookingResponseModel?> result = await _remoteDataSource.getBookingDetails(
      bookingId: event.bookingId,
    );
    result.when(
      success: (data) {
        if (data != null) {
          bookingDetails = data.data;
          emit(BookingsSuccess());
        } else {
          emit(const BookingsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(BookingsError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _createBooking(CreateBookingEvent event, Emitter<BookingsState> emit) async {
    emit(BookingsLoading());
    final ApiResultModel<BookingResponseModel?> result = await _remoteDataSource.createBooking(
      request: event.request,
    );
    result.when(
      success: (data) {
        if (data != null) {
          bookingDetails = data.data;
          emit(BookingsSuccess());
        } else {
          emit(const BookingsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(BookingsError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _checkVoucher(CheckVoucherEvent event, Emitter<BookingsState> emit) async {
    emit(BookingsLoading());
    final ApiResultModel<VoucherResponseModel?> result = await _remoteDataSource.checkVoucher(
      request: event.request,
    );
    result.when(
      success: (data) {
        if (data != null) {
          voucherDetails = data;
          emit(BookingsSuccess());
        } else {
          emit(const BookingsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(BookingsError(message: error.message ?? errorMessage));
      },
    );
  }
}

