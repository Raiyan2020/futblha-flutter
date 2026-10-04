import 'package:json_annotation/json_annotation.dart';

part 'position_model.g.dart';

@JsonSerializable()
class PositionModel {
  final String key;
  final String name;

  PositionModel({
    required this.key,
    required this.name,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) => _$PositionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PositionModelToJson(this);
}

