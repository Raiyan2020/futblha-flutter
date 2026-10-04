// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questions_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionsResponseModel _$QuestionsResponseModelFromJson(
  Map<String, dynamic> json,
) => QuestionsResponseModel(
  levels: (json['levels'] as List<dynamic>?)
      ?.map((e) => LevelsBean.fromJson(e as Map<String, dynamic>))
      .toList(),
  questions_count: json['questions_count'] as num?,
  questions_answered: json['questions_answered'] as num?,
  correct_answers: json['correct_answers'] as num?,
);

Map<String, dynamic> _$QuestionsResponseModelToJson(
  QuestionsResponseModel instance,
) => <String, dynamic>{
  'levels': instance.levels,
  'questions_count': instance.questions_count,
  'questions_answered': instance.questions_answered,
  'correct_answers': instance.correct_answers,
};

LevelsBean _$LevelsBeanFromJson(Map<String, dynamic> json) => LevelsBean(
  name: json['name'] as String?,
  questions_count: json['questions_count'] as num?,
  questions_answered: json['questions_answered'] as num?,
  correct_answers: json['correct_answers'] as num?,
  questions: (json['questions'] as List<dynamic>?)
      ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LevelsBeanToJson(LevelsBean instance) =>
    <String, dynamic>{
      'name': instance.name,
      'questions_count': instance.questions_count,
      'questions_answered': instance.questions_answered,
      'correct_answers': instance.correct_answers,
      'questions': instance.questions,
    };

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      body: json['body'] as String?,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      is_answered: json['is_answered'] as bool?,
      is_correct: json['is_correct'],
      isCurrent: json['isCurrent'] as bool?,
      answer: json['answer'],
      question_answer: json['question_answer'],
      level: json['level'] == null
          ? null
          : LevelModel.fromJson(json['level'] as Map<String, dynamic>),
      questionNumber: (json['questionNumber'] as num?)?.toInt(),
      questionsCount: (json['questionsCount'] as num?)?.toInt(),
    )..question_id = (json['question_id'] as num?)?.toInt();

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question_id': instance.question_id,
      'title': instance.title,
      'body': instance.body,
      'choices': instance.choices,
      'is_answered': instance.is_answered,
      'is_correct': instance.is_correct,
      'isCurrent': instance.isCurrent,
      'answer': instance.answer,
      'question_answer': instance.question_answer,
      'level': instance.level,
      'questionNumber': instance.questionNumber,
      'questionsCount': instance.questionsCount,
    };

LevelModel _$LevelModelFromJson(Map<String, dynamic> json) => LevelModel(
  id: json['id'] as num?,
  name: json['name'] as String?,
  category_id: json['category_id'] as num?,
  created_at: json['created_at'] as String?,
  updated_at: json['updated_at'] as String?,
);

Map<String, dynamic> _$LevelModelToJson(LevelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category_id': instance.category_id,
      'created_at': instance.created_at,
      'updated_at': instance.updated_at,
    };
