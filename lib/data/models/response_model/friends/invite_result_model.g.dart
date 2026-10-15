// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteResultModel _$InviteResultModelFromJson(Map<String, dynamic> json) =>
    InviteResultModel(
      userId: (json['user_id'] as num?)?.toInt(),
      status: json['status'] as String?,
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$InviteResultModelToJson(InviteResultModel instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'status': instance.status,
      'msg': instance.msg,
    };
