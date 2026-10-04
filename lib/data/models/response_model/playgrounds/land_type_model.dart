import 'package:json_annotation/json_annotation.dart';

part 'land_type_model.g.dart';

@JsonSerializable()
class LandTypeModel {
  final String? key;
  final String? name;

  LandTypeModel({
    this.key,
    this.name,
  });

  factory LandTypeModel.fromJson(Map<String, dynamic> json) => _$LandTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$LandTypeModelToJson(this);
}

