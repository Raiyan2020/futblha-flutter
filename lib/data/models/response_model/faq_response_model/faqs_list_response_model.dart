import 'package:json_annotation/json_annotation.dart';
import 'package:futblha/data/models/response_model/faq_response_model/faq_response_model.dart';

part 'faqs_list_response_model.g.dart';

@JsonSerializable()
class FaqsListResponseModel {
  @JsonKey(defaultValue: [])
  final List<FaqResponseModel> data;

  FaqsListResponseModel({
    List<FaqResponseModel>? data,
  }) : data = data ?? [];

  factory FaqsListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FaqsListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqsListResponseModelToJson(this);
}
