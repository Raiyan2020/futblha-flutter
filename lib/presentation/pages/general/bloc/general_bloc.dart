import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../../../data/datasources/general_remote_datasource/general_remote_datasource.dart';
import '../../../../data/models/response_model/general/country_model.dart';
import '../../../../data/models/response_model/general/city_model.dart';
// import '../../../../data/models/response_model/general/position_model.dart';
import '../../../../data/models/response_model/general/countries_list_response_model.dart';
import '../../../../data/models/response_model/general/cities_list_response_model.dart';
// import '../../../../data/models/response_model/general/positions_list_response_model.dart';
import '../../../../data/models/response_model/general/home_response_model.dart';
import '../../../../data/models/response_model/games/game_model.dart';
import '../../../../application/core/utils/constants/app_constants.dart';

part 'general_event.dart';
part 'general_state.dart';

@injectable
class GeneralBloc extends Bloc<GeneralEvent, GeneralState> {
  final GeneralRemoteDataSource _remoteDataSource;

  // Data stored in bloc
  List<CountryModel> countries = [];
  List<CityModel> cities = [];
  // List<PositionModel> positions = [];
  HomeResponseModel? homeData;
  List<GameModel> upcomingGames = [];

  GeneralBloc(this._remoteDataSource) : super(GeneralInitial()) {
    on<GetCountriesEvent>(_getCountries);
    on<GetCitiesEvent>(_getCities);
    // on<GetPositionsEvent>(_getPositions);
    on<GetHomeEvent>(_getHome);
    on<GetUpcomingGamesEvent>(_getUpcomingGames);
  }

  Future<void> _getCountries(GetCountriesEvent event, Emitter<GeneralState> emit) async {
    emit(GeneralLoading());
    final ApiResultModel<CountriesListResponseModel?> result = await _remoteDataSource
        .getCountries();
    result.when(
      success: (data) {
        if (data != null) {
          countries = data.data;
          emit(GeneralSuccess());
        } else {
          emit(const GeneralError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GeneralError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getCities(GetCitiesEvent event, Emitter<GeneralState> emit) async {
    emit(GeneralLoading());
    final ApiResultModel<CitiesListResponseModel?> result = await _remoteDataSource.getCities();
    result.when(
      success: (data) {
        if (data != null) {
          cities = data.data;
          emit(GeneralSuccess());
        } else {
          emit(const GeneralError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GeneralError(message: error.message ?? errorMessage));
      },
    );
  }

  // Future<void> _getPositions(GetPositionsEvent event, Emitter<GeneralState> emit) async {
  //   emit(GeneralLoading());
  //   final ApiResultModel<PositionsListResponseModel?> result = await _remoteDataSource
  //       .getPositions();
  //   result.when(
  //     success: (data) {
  //       if (data != null) {
  //         positions = data.data;
  //         emit(GeneralSuccess());
  //       } else {
  //         emit(const GeneralError(message: errorMessage));
  //       }
  //     },
  //     failure: (error) {
  //       emit(GeneralError(message: error.message ?? errorMessage));
  //     },
  //   );
  // }

  Future<void> _getHome(GetHomeEvent event, Emitter<GeneralState> emit) async {
    // Prevent duplicate requests if already loading or data exists
    if (state is GeneralLoading || homeData != null) {
      return;
    }

    emit(GeneralLoading());
    final ApiResultModel<HomeResponseModel?> result = await _remoteDataSource.getHome();
    result.when(
      success: (data) {
        if (data != null) {
          homeData = data;
          emit(GeneralSuccess());
        } else {
          emit(const GeneralError(message: errorMessage));
        }
      },
      failure: (error) {
        emit(GeneralError(message: error.message ?? errorMessage));
      },
    );
  }

  Future<void> _getUpcomingGames(GetUpcomingGamesEvent event, Emitter<GeneralState> emit) async {
    emit(GeneralLoading());
    final ApiResultModel<List<GameModel>?> result = await _remoteDataSource.getUpcomingGames();
    result.when(
      success: (games) {
        upcomingGames = games ?? [];
        emit(GeneralSuccess());
      },
      failure: (error) {
        upcomingGames = [];
        emit(GeneralError(message: error.message ?? errorMessage));
      },
    );
  }
}
