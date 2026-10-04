import 'package:json_annotation/json_annotation.dart';

part 'app_settings_model.g.dart';

@JsonSerializable()
class AppSettingsModel {
  String? terms;
  @JsonKey(name: 'privacy_policy')
  String? privacyPolicy;
  String? instagram;
  String? twitter;
  String? tiktok;
  String? phone;
  @JsonKey(name: 'forced_update_android')
  String? forcedUpdateAndroid;
  @JsonKey(name: 'forced_update_ios')
  String? forcedUpdateIos;
  @JsonKey(name: 'android_version')
  String? androidVersion;
  @JsonKey(name: 'ios_version')
  String? iosVersion;
  @JsonKey(name: 'force_close')
  String? forceClose;

  AppSettingsModel({
    this.terms,
    this.privacyPolicy,
    this.instagram,
    this.twitter,
    this.tiktok,
    this.phone,
    this.forcedUpdateAndroid,
    this.forcedUpdateIos,
    this.androidVersion,
    this.iosVersion,
    this.forceClose,
  });

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) => _$AppSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsModelToJson(this);
}
