import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../data/datasources/playgrounds_remote_datasource/playgrounds_remote_datasource.dart';
import '../../../../data/models/response_model/playgrounds/land_type_model.dart';
import '../../../../data/models/response_model/playgrounds/facility_model.dart';
import '../../../../data/models/response_model/playgrounds/capacity_model.dart';
import '../../../../data/models/response_model/playgrounds/playground_model.dart';
import '../../../../data/models/response_model/playgrounds/playground_detail_response_model.dart';
import '../../../../data/models/response_model/playgrounds/land_types_list_response_model.dart';
import '../../../../data/models/response_model/playgrounds/facilities_list_response_model.dart';
import '../../../../data/models/response_model/playgrounds/capacities_list_response_model.dart';
import '../../../../data/models/response_model/playgrounds/playgrounds_list_response_model.dart';
import '../../../../data/models/request_model/playgrounds/playground_filter_request_model.dart';
import '../../../../data/models/request_model/playgrounds/add_rate_request_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';

part 'playgrounds_event.dart';
part 'playgrounds_state.dart';

@injectable
class PlaygroundsBloc extends Bloc<PlaygroundsEvent, PlaygroundsState> {
  final PlaygroundsRemoteDataSource _remoteDataSource;

  // Data stored in bloc
  List<LandTypeModel> landTypes = [];
  List<FacilityModel> facilities = [];
  List<CapacityModel> capacities = [];
  List<PlaygroundModel> playgrounds = [];
  PlaygroundDetailResponseModel? playgroundDetails;
  PlaygroundFilterRequestModel? currentFilters;

  PlaygroundsBloc(this._remoteDataSource) : super(PlaygroundsInitial()) {
    on<GetLandTypesEvent>(_getLandTypes);
    on<GetFacilitiesEvent>(_getFacilities);
    on<GetCapacitiesEvent>(_getCapacities);
    on<GetPlaygroundsEvent>(_getPlaygrounds);
    on<GetPlaygroundDetailsEvent>(_getPlaygroundDetails);
    on<AddRateEvent>(_addRate);
  }

  Future<void> _getLandTypes(GetLandTypesEvent event, Emitter<PlaygroundsState> emit) async {
    emit(PlaygroundsLoading());
    final ApiResultModel<LandTypesListResponseModel?> result = await _remoteDataSource
        .getLandTypes();
    result.when(
      success: (data) {
        if (data != null) {
          landTypes = data.data;
          emit(PlaygroundsSuccess());
        } else {
          emit(const PlaygroundsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(PlaygroundsError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getFacilities(GetFacilitiesEvent event, Emitter<PlaygroundsState> emit) async {
    emit(PlaygroundsLoading());
    final ApiResultModel<FacilitiesListResponseModel?> result = await _remoteDataSource
        .getFacilities();
    result.when(
      success: (data) {
        if (data != null) {
          facilities = data.data;
          emit(PlaygroundsSuccess());
        } else {
          emit(const PlaygroundsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(PlaygroundsError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getCapacities(GetCapacitiesEvent event, Emitter<PlaygroundsState> emit) async {
    emit(PlaygroundsLoading());
    final ApiResultModel<CapacitiesListResponseModel?> result = await _remoteDataSource
        .getCapacities();
    result.when(
      success: (data) {
        if (data != null) {
          capacities = data.data;
          emit(PlaygroundsSuccess());
        } else {
          emit(const PlaygroundsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(PlaygroundsError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getPlaygrounds(GetPlaygroundsEvent event, Emitter<PlaygroundsState> emit) async {
    emit(PlaygroundsLoading());
    currentFilters = event.filters;
    final ApiResultModel<PlaygroundsListResponseModel?> result = await _remoteDataSource
        .getPlaygrounds(filters: event.filters);
    result.when(
      success: (data) {
        if (data != null) {
          playgrounds = data.items;
          emit(PlaygroundsSuccess());
        } else {
          emit(const PlaygroundsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(PlaygroundsError(message: error.message ?? errorMessage));
      },
    );
  }

  /// Check if there are active filters (excluding search name)
  bool hasActiveFilters() {
    return currentFilters?.hasActiveFilters() ?? false;
  }

  Future<void> _getPlaygroundDetails(
    GetPlaygroundDetailsEvent event,
    Emitter<PlaygroundsState> emit,
  ) async {
    emit(PlaygroundsLoading());
    final ApiResultModel<PlaygroundDetailResponseModel?> result = await _remoteDataSource
        .getPlaygroundDetails(playgroundId: event.playgroundId, date: event.date);
    result.when(
      success: (data) {
        if (data != null) {
          playgroundDetails = data;
          emit(PlaygroundsSuccess());
        } else {
          emit(const PlaygroundsError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(PlaygroundsError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _addRate(AddRateEvent event, Emitter<PlaygroundsState> emit) async {
    emit(PlaygroundsLoading());
    final request = AddRateRequestModel(playgroundId: event.playgroundId, rate: event.rate);
    final ApiResultModel<String?> result = await _remoteDataSource.addRate(request: request);
    result.when(
      success: (data) {
        emit(PlaygroundsSuccess());
      },
      failure: (error) {
        emit(PlaygroundsError(message: error.message ?? errorMessage));
      },
    );
  }
}
