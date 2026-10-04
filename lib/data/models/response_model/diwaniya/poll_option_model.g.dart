// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poll_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PollOptionModel _$PollOptionModelFromJson(Map<String, dynamic> json) =>
    PollOptionModel(
      id: (json['id'] as num?)?.toInt(),
      optionText: json['option_text'] as String?,
      votesCount: (json['votes_count'] as num?)?.toInt(),
      voters: (json['voters'] as List<dynamic>?)
          ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PollOptionModelToJson(PollOptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'option_text': instance.optionText,
      'votes_count': instance.votesCount,
      'voters': instance.voters,
    };
