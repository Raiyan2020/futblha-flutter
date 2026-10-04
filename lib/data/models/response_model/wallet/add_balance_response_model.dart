import 'package:json_annotation/json_annotation.dart';

part 'add_balance_response_model.g.dart';

@JsonSerializable()
class AddBalanceResponseModel {
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;

  AddBalanceResponseModel({
    this.paymentUrl,
  });

  factory AddBalanceResponseModel.fromJson(Map<String, dynamic> json) => _$AddBalanceResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddBalanceResponseModelToJson(this);
}

