// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventsRequestModel _$EventsRequestModelFromJson(Map<String, dynamic> json) =>
    EventsRequestModel(
      event_id: json['event_id'] as num?,
      question_id: json['question_id'] as num?,
      answer: json['answer'] as String?,
    );

Map<String, dynamic> _$EventsRequestModelToJson(EventsRequestModel instance) =>
    <String, dynamic>{
      'event_id': ?instance.event_id,
      'question_id': ?instance.question_id,
      'answer': ?instance.answer,
    };
