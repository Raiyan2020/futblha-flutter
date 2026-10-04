import 'package:json_annotation/json_annotation.dart';
import 'position_model.dart';

part 'positions_list_response_model.g.dart';

@JsonSerializable()
class PositionsListResponseModel {
  final List<PositionModel> data;

  PositionsListResponseModel({
    required this.data,
  });

  factory PositionsListResponseModel.fromJson(Map<String, dynamic> json) => _$PositionsListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PositionsListResponseModelToJson(this);
}

