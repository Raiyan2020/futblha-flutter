import 'package:json_annotation/json_annotation.dart';

part 'edit_mobile_request_model.g.dart';

@JsonSerializable()
class EditMobileRequestModel {
  final String? userId;
  final String? currentMobile;
  final String? newMobile;
  final String? passsword;

  EditMobileRequestModel({
    this.userId,
    this.currentMobile,
    this.newMobile,
    this.passsword,
  });

  factory EditMobileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$EditMobileRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$EditMobileRequestModelToJson(this);
}
