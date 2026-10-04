// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeResponseModel _$HomeResponseModelFromJson(Map<String, dynamic> json) =>
    HomeResponseModel(
      banners: (json['banners'] as List<dynamic>?)
          ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topRanking: (json['top_ranking'] as List<dynamic>?)
          ?.map((e) => DiwaniyaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeGames: (json['active_games'] as List<dynamic>?)
          ?.map((e) => GameModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingGames: (json['upcoming_games'] as List<dynamic>?)
          ?.map((e) => GameModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      playgrounds: (json['playgrounds'] as List<dynamic>?)
          ?.map((e) => PlaygroundModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HomeResponseModelToJson(HomeResponseModel instance) =>
    <String, dynamic>{
      'banners': instance.banners,
      'top_ranking': instance.topRanking,
      'active_games': instance.activeGames,
      'upcoming_games': instance.upcomingGames,
      'playgrounds': instance.playgrounds,
    };
