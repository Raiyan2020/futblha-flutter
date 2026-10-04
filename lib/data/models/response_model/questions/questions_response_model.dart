import 'package:json_annotation/json_annotation.dart';

import '../../enums/question_status.dart';

part 'questions_response_model.g.dart';

@JsonSerializable()
class QuestionsResponseModel {
  List<LevelsBean>? levels;
  num? questions_count;
  num? questions_answered;
  num? correct_answers;

  QuestionsResponseModel({this.levels, this.questions_count, this.questions_answered, this.correct_answers});

  factory QuestionsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionsResponseModelToJson(this);
}

@JsonSerializable()
class LevelsBean {
  String? name;
  num? questions_count;
  num? questions_answered;
  num? correct_answers;
  List<QuestionModel>? questions;

  LevelsBean(
      {this.name, this.questions_count, this.questions_answered, this.correct_answers, this.questions});

  factory LevelsBean.fromJson(Map<String, dynamic> json) => _$LevelsBeanFromJson(json);

  Map<String, dynamic> toJson() => _$LevelsBeanToJson(this);
}

@JsonSerializable()
class QuestionModel {
  int? id;
  int? question_id;
  String? title;
  String? body;
  List<String>? choices;
  bool? is_answered;
  dynamic is_correct;
  bool? isCurrent;
  dynamic answer;
  dynamic question_answer;
  LevelModel? level;

  int? questionNumber;
  int? questionsCount;

  bool get isCorrect {
    if (is_correct == true || is_correct == 1) {
      return true;
    } else {
      return false;
    }
  }

  QuestionStatus get state {
    if (is_answered == true && isCorrect == true) {
      return QuestionStatus.correct;
    } else if (is_answered == true && isCorrect == false) {
      return QuestionStatus.incorrect;
    } else if (isCurrent == true) {
      return QuestionStatus.current;
    } else {
      return QuestionStatus.notAnswered;
    }
  }

  QuestionModel({
    this.id,
    this.title,
    this.body,
    this.choices,
    this.is_answered,
    this.is_correct,
    this.isCurrent,
    this.answer,
    this.question_answer,
    this.level,
    this.questionNumber,
    this.questionsCount,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);
}

@JsonSerializable()
class LevelModel {
  num? id;
  String? name;
  num? category_id;
  String? created_at;
  String? updated_at;

  LevelModel({this.id, this.name, this.category_id, this.created_at, this.updated_at});

  factory LevelModel.fromJson(Map<String, dynamic> json) => _$LevelModelFromJson(json);

  Map<String, dynamic> toJson() => _$LevelModelToJson(this);
}
