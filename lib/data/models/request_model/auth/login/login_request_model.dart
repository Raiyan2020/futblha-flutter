import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

@JsonSerializable()
class LoginRequestModel {
  @JsonKey(name: 'phone', includeIfNull: false)
  final String? phone;
  @JsonKey(name: 'name', includeIfNull: false)
  final String? name;
  @JsonKey(name: 'birthdate', includeIfNull: false)
  final String? birthdate;
  @JsonKey(name: 'country_code', includeIfNull: false)
  final String? countryCode;
  @JsonKey(name: 'email', includeIfNull: false)
  final String? email;
  @JsonKey(name: 'device_token', includeIfNull: false)
  final String? deviceToken;
  @JsonKey(name: 'device_type', includeIfNull: false)
  final String? deviceType;

  LoginRequestModel({
    this.phone,
    this.name,
    this.birthdate,
    this.countryCode,
    this.email,
    this.deviceToken,
    this.deviceType,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);

  LoginRequestModel copyWith({
    String? phone,
    String? name,
    String? countryCode,
    String? email,
    String? deviceToken,
    String? deviceType,
    String? birthdate,
  }) {
    return LoginRequestModel(
      phone: phone ?? this.phone,
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      email: email ?? this.email,
      deviceToken: deviceToken ?? this.deviceToken,
      deviceType: deviceType ?? this.deviceType,
      birthdate: birthdate ?? this.birthdate,
    );
  }
}
