import 'package:json_annotation/json_annotation.dart';

part 'profession_model.g.dart';

@JsonSerializable()
class ProfessionModel {
  num? id;
  String? name;

  ProfessionModel({this.id, this.name});

  factory ProfessionModel.fromJson(Map<String, dynamic> json) => _$ProfessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessionModelToJson(this);
}
