// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventsResponseModel _$EventsResponseModelFromJson(Map<String, dynamic> json) =>
    EventsResponseModel(
      event: json['event'] == null
          ? null
          : EventBean.fromJson(json['event'] as Map<String, dynamic>),
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      my_correct_answers: json['my_correct_answers'] as num?,
      score: json['score'] as num?,
    );

Map<String, dynamic> _$EventsResponseModelToJson(
  EventsResponseModel instance,
) => <String, dynamic>{
  'event': instance.event,
  'questions': instance.questions,
  'my_correct_answers': instance.my_correct_answers,
  'score': instance.score,
};

EventBean _$EventBeanFromJson(Map<String, dynamic> json) => EventBean(
  id: json['id'] as num?,
  start_date: json['start_date'] as String?,
  end_date: json['end_date'] as String?,
  is_active: json['is_active'] as bool?,
);

Map<String, dynamic> _$EventBeanToJson(EventBean instance) => <String, dynamic>{
  'id': instance.id,
  'start_date': instance.start_date,
  'end_date': instance.end_date,
  'is_active': instance.is_active,
};
