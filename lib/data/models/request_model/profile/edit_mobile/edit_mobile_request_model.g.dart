// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_mobile_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditMobileRequestModel _$EditMobileRequestModelFromJson(
  Map<String, dynamic> json,
) => EditMobileRequestModel(
  userId: json['userId'] as String?,
  currentMobile: json['currentMobile'] as String?,
  newMobile: json['newMobile'] as String?,
  passsword: json['passsword'] as String?,
);

Map<String, dynamic> _$EditMobileRequestModelToJson(
  EditMobileRequestModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'currentMobile': instance.currentMobile,
  'newMobile': instance.newMobile,
  'passsword': instance.passsword,
};
