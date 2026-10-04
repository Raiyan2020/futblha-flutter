import 'package:json_annotation/json_annotation.dart';

part 'payment_method_response_model.g.dart';

@JsonSerializable()
class PaymentMethodResponseModel {
  final String? key;
  final String? name;

  PaymentMethodResponseModel({
    this.key,
    this.name,
  });

  factory PaymentMethodResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodResponseModelToJson(this);
}
