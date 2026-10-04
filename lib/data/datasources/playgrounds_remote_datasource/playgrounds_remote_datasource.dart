import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/response_model/playgrounds/land_types_list_response_model.dart';
import '../../models/response_model/playgrounds/facilities_list_response_model.dart';
import '../../models/response_model/playgrounds/capacities_list_response_model.dart';
import '../../models/response_model/playgrounds/playgrounds_list_response_model.dart';
import '../../models/response_model/playgrounds/playground_detail_response_model.dart';
import '../../models/response_model/playgrounds/bookings_list_response_model.dart';
import '../../models/response_model/playgrounds/booking_response_model.dart';
import '../../models/response_model/playgrounds/voucher_response_model.dart';
import '../../models/request_model/playgrounds/playground_filter_request_model.dart';
import '../../models/request_model/playgrounds/booking_request_model.dart';
import '../../models/request_model/playgrounds/voucher_request_model.dart';
import '../../models/request_model/playgrounds/add_rate_request_model.dart';

abstract class PlaygroundsRemoteDataSource {
  Future<ApiResultModel<LandTypesListResponseModel?>> getLandTypes();

  Future<ApiResultModel<FacilitiesListResponseModel?>> getFacilities();

  Future<ApiResultModel<CapacitiesListResponseModel?>> getCapacities();

  Future<ApiResultModel<PlaygroundsListResponseModel?>> getPlaygrounds({
    PlaygroundFilterRequestModel? filters,
  });

  Future<ApiResultModel<PlaygroundDetailResponseModel?>> getPlaygroundDetails({
    required int playgroundId,
    String? date,
  });

  Future<ApiResultModel<BookingResponseModel?>> createBooking({
    required BookingRequestModel request,
  });

  Future<ApiResultModel<BookingsListResponseModel?>> getBookings();

  Future<ApiResultModel<BookingResponseModel?>> getBookingDetails({
    required int bookingId,
  });

  Future<ApiResultModel<VoucherResponseModel?>> checkVoucher({
    required VoucherRequestModel request,
  });

  Future<ApiResultModel<String?>> addRate({
    required AddRateRequestModel request,
  });
}

