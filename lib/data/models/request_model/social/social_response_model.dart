import 'package:json_annotation/json_annotation.dart';

part 'social_response_model.g.dart';

@JsonSerializable()
class SocialResponseModel {
  String? twitter;
  String? tiktok;
  String? snapchat;
  String? instagram;

  SocialResponseModel({this.twitter, this.tiktok, this.snapchat, this.instagram});

  factory SocialResponseModel.fromJson(Map<String, dynamic> json) => _$SocialResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SocialResponseModelToJson(this);
}
