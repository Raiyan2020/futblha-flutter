// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pusher_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PusherResultModel _$PusherResultModelFromJson(Map<String, dynamic> json) =>
    PusherResultModel(
      challengeResultResource: json['challengeResultResource'] == null
          ? null
          : ChallengeResultResourceBean.fromJson(
              json['challengeResultResource'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PusherResultModelToJson(PusherResultModel instance) =>
    <String, dynamic>{
      'challengeResultResource': instance.challengeResultResource,
    };

ChallengeResultResourceBean _$ChallengeResultResourceBeanFromJson(
  Map<String, dynamic> json,
) => ChallengeResultResourceBean(
  id: json['id'] as num?,
  is_active: json['is_active'] as num?,
  admin_team_result: json['admin_team_result'] as num?,
  other_team_result: json['other_team_result'] as num?,
  my_correct_answers: json['my_correct_answers'] as num?,
);

Map<String, dynamic> _$ChallengeResultResourceBeanToJson(
  ChallengeResultResourceBean instance,
) => <String, dynamic>{
  'id': instance.id,
  'is_active': instance.is_active,
  'admin_team_result': instance.admin_team_result,
  'other_team_result': instance.other_team_result,
  'my_correct_answers': instance.my_correct_answers,
};
