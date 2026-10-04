import 'package:json_annotation/json_annotation.dart';
import 'facility_model.dart';

part 'facilities_list_response_model.g.dart';

@JsonSerializable()
class FacilitiesListResponseModel {
  final List<FacilityModel> data;

  FacilitiesListResponseModel({
    required this.data,
  });

  factory FacilitiesListResponseModel.fromJson(Map<String, dynamic> json) => _$FacilitiesListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FacilitiesListResponseModelToJson(this);
}

