// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diwaniya_ranking_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiwaniyaRankingResponseModel _$DiwaniyaRankingResponseModelFromJson(
  Map<String, dynamic> json,
) => DiwaniyaRankingResponseModel(
  topRanking: (json['top_ranking'] as List<dynamic>?)
      ?.map((e) => DiwaniyaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  allRanking: json['all_ranking'] == null
      ? null
      : DiwaniyasListResponseModel.fromJson(
          json['all_ranking'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DiwaniyaRankingResponseModelToJson(
  DiwaniyaRankingResponseModel instance,
) => <String, dynamic>{
  'top_ranking': instance.topRanking,
  'all_ranking': instance.allRanking,
};
