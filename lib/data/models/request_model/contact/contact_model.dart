import 'package:json_annotation/json_annotation.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel {
  String? name;
  String? email; // Changed from email to phone
  String? message;

  ContactModel({this.name, this.email, this.message}); // Changed constructor

  factory ContactModel.fromJson(Map<String, dynamic> json) => _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);
}