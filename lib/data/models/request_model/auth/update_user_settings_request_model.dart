import 'package:json_annotation/json_annotation.dart';

part 'update_user_settings_request_model.g.dart';

@JsonSerializable()
class UpdateUserSettingsRequestModel {
  @JsonKey(name: 'notification_enabled')
  final String? notificationEnabled;
  @JsonKey(name: 'language')
  final String? language;

  UpdateUserSettingsRequestModel({
    this.notificationEnabled,
    this.language,
  });

  factory UpdateUserSettingsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserSettingsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUserSettingsRequestModelToJson(this);
}