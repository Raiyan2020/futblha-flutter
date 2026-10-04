import 'package:json_annotation/json_annotation.dart';

part 'settings_response_model.g.dart';

@JsonSerializable()
class SettingsResponseModel {
  @JsonKey(name: 'about_us')
  final String? aboutUs;
  final String? terms;
  final String? phone;
  final String? email;
  final String? facebook;
  final String? twitter;
  final String? instagram;
  final String? whatsapp;
  final String? messenger;
  final String? privacy;
  final String? tiktok;
  @JsonKey(name: 'wallet_usage_percentage')
  final String? walletUsagePercentage;
  @JsonKey(name: 'win_points')
  final String? winPoints;
  @JsonKey(name: 'draw_points')
  final String? drawPoints;

  SettingsResponseModel({
    this.aboutUs,
    this.terms,
    this.phone,
    this.email,
    this.facebook,
    this.twitter,
    this.instagram,
    this.whatsapp,
    this.messenger,
    this.privacy,
    this.tiktok,
    this.walletUsagePercentage,
    this.winPoints,
    this.drawPoints,
  });

  factory SettingsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsResponseModelToJson(this);
}
