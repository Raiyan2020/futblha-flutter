import 'package:json_annotation/json_annotation.dart';
import '../diwaniya/diwaniya_model.dart';
import '../games/game_model.dart';
import '../playgrounds/playground_model.dart';
import 'banner_model.dart';

part 'home_response_model.g.dart';

@JsonSerializable()
class HomeResponseModel {
  final List<BannerModel>? banners;
  @JsonKey(name: 'top_ranking')
  final List<DiwaniyaModel>? topRanking;
  @JsonKey(name: 'active_games')
  final List<GameModel>? activeGames;
  @JsonKey(name: 'upcoming_games')
  final List<GameModel>? upcomingGames;
  final List<PlaygroundModel>? playgrounds;

  HomeResponseModel({
    this.banners,
    this.topRanking,
    this.activeGames,
    this.upcomingGames,
    this.playgrounds,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HomeResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeResponseModelToJson(this);
}
