import 'package:json_annotation/json_annotation.dart';
import 'game_model.dart';
import '../diwaniya/paginate_model.dart';

part 'game_history_response_model.g.dart';

@JsonSerializable()
class GameHistoryResponseModel {
  final List<GameModel>? items;
  final PaginateModel? paginate;
  final dynamic extra;

  GameHistoryResponseModel({this.items, this.paginate, this.extra});

  factory GameHistoryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GameHistoryResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameHistoryResponseModelToJson(this);
}
