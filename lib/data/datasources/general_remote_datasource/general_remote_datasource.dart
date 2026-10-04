import '../../../application/core/commundomain/entitties/based_api_result/api_result_model.dart';
import '../../models/response_model/general/countries_list_response_model.dart';
import '../../models/response_model/general/cities_list_response_model.dart';
import '../../models/response_model/general/positions_list_response_model.dart';
import '../../models/response_model/general/home_response_model.dart';
import '../../models/response_model/games/game_model.dart';

abstract class GeneralRemoteDataSource {
  Future<ApiResultModel<CountriesListResponseModel?>> getCountries();

  Future<ApiResultModel<CitiesListResponseModel?>> getCities();

  Future<ApiResultModel<PositionsListResponseModel?>> getPositions();

  Future<ApiResultModel<HomeResponseModel?>> getHome();

  Future<ApiResultModel<List<GameModel>?>> getUpcomingGames();
}
