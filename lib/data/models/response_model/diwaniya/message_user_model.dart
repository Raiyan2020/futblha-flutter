import 'package:json_annotation/json_annotation.dart';

part 'message_user_model.g.dart';

@JsonSerializable()
class MessageUserModel {
  final int? id;
  final String? name;
  final String? image;

  MessageUserModel({
    this.id,
    this.name,
    this.image,
  });

  factory MessageUserModel.fromJson(Map<String, dynamic> json) => _$MessageUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageUserModelToJson(this);
}

