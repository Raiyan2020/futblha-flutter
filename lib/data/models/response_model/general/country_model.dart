import 'package:json_annotation/json_annotation.dart';

part 'country_model.g.dart';

@JsonSerializable()
class CountryModel {
  final int id;
  final String name;
  final String? image;
  @JsonKey(name: 'country_code')
  final String countryCode;

  CountryModel({
    required this.id,
    required this.name,
    this.image,
    required this.countryCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => _$CountryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountryModelToJson(this);
}

