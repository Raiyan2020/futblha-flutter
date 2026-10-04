import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../application/core/commundomain/entitties/based_api_result/error_result_model.dart';
import '../../../../application/core/di/app_component/app_component.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/helpers/custom_exceptions/custom_connection_exception.dart';
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
import '../../network/dio_strategy_helper/concrete_strategies/get_request_strategy.dart';
import '../../network/dio_strategy_helper/concrete_strategies/post_request_strategy.dart';
import '../../network/dio_strategy_helper/dio_request_context.dart';
import 'playgrounds_remote_datasource.dart';

@Injectable(as: PlaygroundsRemoteDataSource)
class PlaygroundsRemoteDataSourceImpl implements PlaygroundsRemoteDataSource {
  const PlaygroundsRemoteDataSourceImpl(this._apiCallHelper);
  final DioRequestContext _apiCallHelper;

  @override
  Future<ApiResultModel<LandTypesListResponseModel?>> getLandTypes() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: LandTypes,
      );
      return result.when(
        success: (Response response) async {
          final result = LandTypesListResponseModel.fromJson({'data': response.data['data']});
          return ApiResultModel<LandTypesListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<LandTypesListResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<FacilitiesListResponseModel?>> getFacilities() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Facilities,
      );
      return result.when(
        success: (Response response) async {
          final result = FacilitiesListResponseModel.fromJson({'data': response.data['data']});
          return ApiResultModel<FacilitiesListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<FacilitiesListResponseModel?>.failure(
            errorResultEntity: errorModel,
          );
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<CapacitiesListResponseModel?>> getCapacities() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Capacities,
      );
      return result.when(
        success: (Response response) async {
          final result = CapacitiesListResponseModel.fromJson({'data': response.data['data']});
          return ApiResultModel<CapacitiesListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<CapacitiesListResponseModel?>.failure(
            errorResultEntity: errorModel,
          );
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<PlaygroundsListResponseModel?>> getPlaygrounds({
    PlaygroundFilterRequestModel? filters,
  }) async {
    try {
      final queryParams = filters?.toQueryParams() ?? {};
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Playgrounds,
        requestData: queryParams,
      );
      return result.when(
        success: (Response response) async {
          final result = PlaygroundsListResponseModel.fromJson(response.data['data']);
          return ApiResultModel<PlaygroundsListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<PlaygroundsListResponseModel?>.failure(
            errorResultEntity: errorModel,
          );
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<PlaygroundDetailResponseModel?>> getPlaygroundDetails({
    required int playgroundId,
    String? date,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final uri = '$Playgrounds/$playgroundId';
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: uri,
        requestData: queryParams.isNotEmpty ? queryParams : null,
      );
      return result.when(
        success: (Response response) async {
          final result = PlaygroundDetailResponseModel.fromJson(response.data['data']);
          return ApiResultModel<PlaygroundDetailResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<PlaygroundDetailResponseModel?>.failure(
            errorResultEntity: errorModel,
          );
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<BookingResponseModel?>> createBooking({
    required BookingRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Bookings,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final result = BookingResponseModel.fromJson(response.data);
          return ApiResultModel<BookingResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<BookingResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<BookingsListResponseModel?>> getBookings() async {
    try {
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: Bookings,
      );
      return result.when(
        success: (Response response) async {
          final result = BookingsListResponseModel.fromJson({'data': response.data['data']});
          return ApiResultModel<BookingsListResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<BookingsListResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<BookingResponseModel?>> getBookingDetails({required int bookingId}) async {
    try {
      final uri = '$Bookings/$bookingId';
      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<GetRequestStrategy>(),
        uri: uri,
      );
      return result.when(
        success: (Response response) async {
          final result = BookingResponseModel.fromJson(response.data);
          return ApiResultModel<BookingResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<BookingResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<VoucherResponseModel?>> checkVoucher({
    required VoucherRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: Vouchers,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final result = VoucherResponseModel.fromJson(response.data['data']);
          return ApiResultModel<VoucherResponseModel?>.success(data: result);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<VoucherResponseModel?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }

  @override
  Future<ApiResultModel<String?>> addRate({
    required AddRateRequestModel request,
  }) async {
    try {
      final formData = FormData.fromMap(request.toFormData());

      final ApiResultModel<Response> result = await _apiCallHelper.makeRequest(
        dioRequestStrategy: locator<PostRequestStrategy>(),
        uri: AddRate,
        formData: formData,
      );
      return result.when(
        success: (Response response) async {
          final message = response.data['data'] as String?;
          return ApiResultModel<String?>.success(data: message);
        },
        failure: (ErrorResultModel errorModel) {
          return ApiResultModel<String?>.failure(errorResultEntity: errorModel);
        },
      );
    } on CustomConnectionException catch (exception) {
      throw CustomConnectionException(
        exceptionMessage: exception.exceptionMessage,
        exceptionCode: exception.exceptionCode,
      );
    }
  }
}
