import 'package:json_annotation/json_annotation.dart';

part 'diwaniya_member_model.g.dart';

@JsonSerializable()
class DiwaniyaMemberModel {
  final int? id;
  final String? name;
  final String? image;
  final String? role;

  DiwaniyaMemberModel({
    this.id,
    this.name,
    this.image,
    this.role,
  });

  factory DiwaniyaMemberModel.fromJson(Map<String, dynamic> json) => _$DiwaniyaMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiwaniyaMemberModelToJson(this);
}

