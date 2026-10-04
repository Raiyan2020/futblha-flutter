import 'package:json_annotation/json_annotation.dart';
import 'diwaniya_model.dart';
import 'paginate_model.dart';

part 'diwaniyas_list_response_model.g.dart';

@JsonSerializable()
class DiwaniyasListResponseModel {
  final List<DiwaniyaModel>? items;
  final PaginateModel? paginate;
  final dynamic extra;

  DiwaniyasListResponseModel({
    this.items,
    this.paginate,
    this.extra,
  });

  factory DiwaniyasListResponseModel.fromJson(Map<String, dynamic> json) => _$DiwaniyasListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiwaniyasListResponseModelToJson(this);
}

