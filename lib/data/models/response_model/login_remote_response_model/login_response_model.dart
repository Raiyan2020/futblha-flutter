// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  String? token;
  UserModel? user;

  LoginResponseModel({this.token, this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UserModel extends Equatable {
  String? balance;
  num? id;
  String? name;
  String? phone;
  String? email;
  String? image;
  String? country_code;
  String? device_type;
  String? status;
  String? phone_not_code;
  String? language;
  bool? notification_enabled;
  String? last_result;
  String? birthdate;
  @JsonKey(name: 'position')
  List<String>? positions;
  int? age;
  @JsonKey(name: 'is_notifications_allowed')
  bool? isNotificationsAllowed;

  UserModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.image,
    this.country_code,
    this.device_type,
    this.status,
    this.phone_not_code,
    this.language,
    this.notification_enabled,
    this.last_result,
    this.birthdate,
    this.positions,
    this.age,
    this.isNotificationsAllowed,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id];
}
