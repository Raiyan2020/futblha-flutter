// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as num?,
      name: json['name'] as String?,
      questions_count: json['questions_count'] as num?,
      correct_answers: json['correct_answers'] as num?,
      questions_answered: json['questions_answered'] as num?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'questions_count': instance.questions_count,
      'correct_answers': instance.correct_answers,
      'questions_answered': instance.questions_answered,
      'image': instance.image,
    };
