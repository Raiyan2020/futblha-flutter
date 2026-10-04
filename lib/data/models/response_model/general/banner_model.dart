import 'package:json_annotation/json_annotation.dart';

part 'banner_model.g.dart';

@JsonSerializable()
class BannerModel {
  final int? id;
  final String? title;
  final String? image;
  final String? url;
  final String? description;

  BannerModel({this.id, this.title, this.image, this.url, this.description});

  factory BannerModel.fromJson(Map<String, dynamic> json) => _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}
