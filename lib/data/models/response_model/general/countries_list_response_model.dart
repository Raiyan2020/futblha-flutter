import 'package:json_annotation/json_annotation.dart';
import 'country_model.dart';

part 'countries_list_response_model.g.dart';

@JsonSerializable()
class CountriesListResponseModel {
  final List<CountryModel> data;

  CountriesListResponseModel({
    required this.data,
  });

  factory CountriesListResponseModel.fromJson(Map<String, dynamic> json) => _$CountriesListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountriesListResponseModelToJson(this);
}

