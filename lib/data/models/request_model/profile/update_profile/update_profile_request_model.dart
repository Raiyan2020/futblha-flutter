import 'package:json_annotation/json_annotation.dart';

part 'update_profile_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateProfileRequestModel {
  String? phone;
  String? currentPassword;
  String? newPassword;
  String? confirmPassword;

  UpdateProfileRequestModel({this.phone, this.currentPassword, this.newPassword, this.confirmPassword});

  factory UpdateProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestModelToJson(this);
}
