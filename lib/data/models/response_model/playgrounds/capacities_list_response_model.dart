import 'package:json_annotation/json_annotation.dart';
import 'capacity_model.dart';

part 'capacities_list_response_model.g.dart';

@JsonSerializable()
class CapacitiesListResponseModel {
  final List<CapacityModel> data;

  CapacitiesListResponseModel({
    required this.data,
  });

  factory CapacitiesListResponseModel.fromJson(Map<String, dynamic> json) => _$CapacitiesListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CapacitiesListResponseModelToJson(this);
}

