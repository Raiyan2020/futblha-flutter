import 'package:json_annotation/json_annotation.dart';

part 'facility_model.g.dart';

@JsonSerializable()
class FacilityModel {
  final int? id;
  final String? name;
  final String? image;

  FacilityModel({
    this.id,
    this.name,
    this.image,
  });

  factory FacilityModel.fromJson(Map<String, dynamic> json) => _$FacilityModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacilityModelToJson(this);
}

