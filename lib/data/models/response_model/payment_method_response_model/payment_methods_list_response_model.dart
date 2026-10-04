import 'package:json_annotation/json_annotation.dart';
import 'package:futblha/data/models/response_model/payment_method_response_model/payment_method_response_model.dart';

part 'payment_methods_list_response_model.g.dart';

@JsonSerializable()
class PaymentMethodsListResponseModel {
  @JsonKey(defaultValue: [])
  final List<PaymentMethodResponseModel> data;

  PaymentMethodsListResponseModel({
    List<PaymentMethodResponseModel>? data,
  }) : data = data ?? [];

  factory PaymentMethodsListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodsListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodsListResponseModelToJson(this);
}
