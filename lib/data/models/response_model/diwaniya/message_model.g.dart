// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: (json['id'] as num?)?.toInt(),
  type: json['type'] as String?,
  content: json['content'] as String?,
  user: json['user'] == null
      ? null
      : MessageUserModel.fromJson(json['user'] as Map<String, dynamic>),
  senderId: (json['sender_id'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  options: (json['options'] as List<dynamic>?)
      ?.map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'content': instance.content,
      'user': instance.user,
      'sender_id': instance.senderId,
      'created_at': instance.createdAt,
      'options': instance.options,
    };
