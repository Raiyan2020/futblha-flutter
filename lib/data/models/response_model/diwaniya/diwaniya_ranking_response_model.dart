import 'package:json_annotation/json_annotation.dart';
import 'diwaniya_model.dart';
import 'diwaniyas_list_response_model.dart';

part 'diwaniya_ranking_response_model.g.dart';

@JsonSerializable()
class DiwaniyaRankingResponseModel {
  @JsonKey(name: 'top_ranking')
  final List<DiwaniyaModel>? topRanking;
  @JsonKey(name: 'all_ranking')
  final DiwaniyasListResponseModel? allRanking;

  DiwaniyaRankingResponseModel({
    this.topRanking,
    this.allRanking,
  });

  factory DiwaniyaRankingResponseModel.fromJson(Map<String, dynamic> json) => _$DiwaniyaRankingResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiwaniyaRankingResponseModelToJson(this);
}

