import 'package:json_annotation/json_annotation.dart';

part 'contact_response_model.g.dart';

@JsonSerializable()
class ContactResponseModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? message;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  ContactResponseModel({
    this.id,
    this.name,
    this.phone,
    this.message,
    this.userId,
    this.updatedAt,
    this.createdAt,
  });

  factory ContactResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ContactResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactResponseModelToJson(this);
}
