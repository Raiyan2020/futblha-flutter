import 'package:json_annotation/json_annotation.dart';

part 'resend_activation_response_model.g.dart';

@JsonSerializable()
class ResendActivationResponseModel {
  @JsonKey(name: 'resend_code_count')
  final int? resendCodeCount;

  ResendActivationResponseModel({
    this.resendCodeCount,
  });

  factory ResendActivationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ResendActivationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResendActivationResponseModelToJson(this);
}