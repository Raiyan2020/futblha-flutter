import 'package:json_annotation/json_annotation.dart';
import 'playground_model.dart';
import 'pagination_model.dart';

part 'playgrounds_list_response_model.g.dart';

@JsonSerializable()
class PlaygroundsListResponseModel {
  final List<PlaygroundModel> items;
  final PaginationModel paginate;
  final dynamic extra;

  PlaygroundsListResponseModel({
    required this.items,
    required this.paginate,
    this.extra,
  });

  factory PlaygroundsListResponseModel.fromJson(Map<String, dynamic> json) => _$PlaygroundsListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaygroundsListResponseModelToJson(this);
}

