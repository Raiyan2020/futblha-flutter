// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnreadCountModel _$UnreadCountModelFromJson(Map<String, dynamic> json) =>
    UnreadCountModel(
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      pendingInvitationsCount:
          (json['pending_invitations_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UnreadCountModelToJson(UnreadCountModel instance) =>
    <String, dynamic>{
      'unread_count': instance.unreadCount,
      'pending_invitations_count': instance.pendingInvitationsCount,
    };
