import 'package:json_annotation/json_annotation.dart';
import 'land_type_model.dart';

part 'land_types_list_response_model.g.dart';

@JsonSerializable()
class LandTypesListResponseModel {
  final List<LandTypeModel> data;

  LandTypesListResponseModel({
    required this.data,
  });

  factory LandTypesListResponseModel.fromJson(Map<String, dynamic> json) => _$LandTypesListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LandTypesListResponseModelToJson(this);
}

