// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      token: json['token'] as String?,
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{'token': instance.token, 'user': instance.user};

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as num?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  image: json['image'] as String?,
  country_code: json['country_code'] as String?,
  device_type: json['device_type'] as String?,
  status: json['status'] as String?,
  phone_not_code: json['phone_not_code'] as String?,
  language: json['language'] as String?,
  notification_enabled: json['notification_enabled'] as bool?,
  last_result: json['last_result'] as String?,
  birthdate: json['birthdate'] as String?,
  positions: (json['position'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  age: (json['age'] as num?)?.toInt(),
  isNotificationsAllowed: json['is_notifications_allowed'] as bool?,
  balance: json['balance'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'balance': ?instance.balance,
  'id': ?instance.id,
  'name': ?instance.name,
  'phone': ?instance.phone,
  'email': ?instance.email,
  'image': ?instance.image,
  'country_code': ?instance.country_code,
  'device_type': ?instance.device_type,
  'status': ?instance.status,
  'phone_not_code': ?instance.phone_not_code,
  'language': ?instance.language,
  'notification_enabled': ?instance.notification_enabled,
  'last_result': ?instance.last_result,
  'birthdate': ?instance.birthdate,
  'position': ?instance.positions,
  'age': ?instance.age,
  'is_notifications_allowed': ?instance.isNotificationsAllowed,
};
