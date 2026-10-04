import 'package:json_annotation/json_annotation.dart';

part 'capacity_model.g.dart';

@JsonSerializable()
class CapacityModel {
  final int? id;
  final String? name;
  final String? image;

  CapacityModel({
    this.id,
    this.name,
    this.image,
  });

  factory CapacityModel.fromJson(Map<String, dynamic> json) => _$CapacityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CapacityModelToJson(this);
}

