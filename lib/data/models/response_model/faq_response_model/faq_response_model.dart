import 'package:json_annotation/json_annotation.dart';

part 'faq_response_model.g.dart';

@JsonSerializable()
class FaqResponseModel {
  final int? id;
  final String? question;
  final String? answer;
  final int? status;

  FaqResponseModel({
    this.id,
    this.question,
    this.answer,
    this.status,
  });

  factory FaqResponseModel.fromJson(Map<String, dynamic> json) =>
      _$FaqResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$FaqResponseModelToJson(this);
}
