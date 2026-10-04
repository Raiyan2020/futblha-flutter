import 'package:json_annotation/json_annotation.dart';

part 'verify_otp_request_model.g.dart';

@JsonSerializable()
class VerifyOtpRequestModel {
  @JsonKey(name: 'phone')
  final String? phone;
  @JsonKey(name: 'activation_code')
  final String? activationCode;
  @JsonKey(name: 'country_code')
  final String? countryCode;

  VerifyOtpRequestModel({
    this.phone,
    this.activationCode,
    this.countryCode,
  });

  factory VerifyOtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpRequestModelToJson(this);
}