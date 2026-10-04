import 'package:json_annotation/json_annotation.dart';

part 'diwaniya_type_model.g.dart';

@JsonSerializable()
class DiwaniyaTypeModel {
  final String? key;
  final String? name;

  DiwaniyaTypeModel({
    this.key,
    this.name,
  });

  factory DiwaniyaTypeModel.fromJson(Map<String, dynamic> json) => _$DiwaniyaTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiwaniyaTypeModelToJson(this);
}

