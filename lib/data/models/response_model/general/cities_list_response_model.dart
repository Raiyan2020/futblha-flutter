import 'package:json_annotation/json_annotation.dart';
import 'city_model.dart';

part 'cities_list_response_model.g.dart';

@JsonSerializable()
class CitiesListResponseModel {
  final List<CityModel> data;

  CitiesListResponseModel({
    required this.data,
  });

  factory CitiesListResponseModel.fromJson(Map<String, dynamic> json) => _$CitiesListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CitiesListResponseModelToJson(this);
}

