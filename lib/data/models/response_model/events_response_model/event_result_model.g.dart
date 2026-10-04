// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventResultModel _$EventResultModelFromJson(Map<String, dynamic> json) =>
    EventResultModel(
      id: json['id'] as num?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      correct_answers: json['correct_answers'] as num?,
      points: json['points'] as num?,
    );

Map<String, dynamic> _$EventResultModelToJson(EventResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.image,
      'correct_answers': instance.correct_answers,
      'points': instance.points,
    };
