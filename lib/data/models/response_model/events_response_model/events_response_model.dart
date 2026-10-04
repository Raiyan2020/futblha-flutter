import 'package:json_annotation/json_annotation.dart';
import 'package:futblha/data/models/response_model/questions/questions_response_model.dart';

part 'events_response_model.g.dart';

@JsonSerializable()
class EventsResponseModel {
  EventBean? event;
  List<QuestionModel>? questions;
  num? my_correct_answers;
  num? score;

  EventsResponseModel({this.event, this.questions, this.my_correct_answers, this.score});

  factory EventsResponseModel.fromJson(Map<String, dynamic> json) => _$EventsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventsResponseModelToJson(this);
}

@JsonSerializable()
class EventBean {
  num? id;
  String? start_date;
  String? end_date;
  bool? is_active;

  EventBean({this.id, this.start_date, this.end_date, this.is_active});

  factory EventBean.fromJson(Map<String, dynamic> json) => _$EventBeanFromJson(json);

  Map<String, dynamic> toJson() => _$EventBeanToJson(this);
}
