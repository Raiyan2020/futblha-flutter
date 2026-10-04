import 'package:json_annotation/json_annotation.dart';

part 'event_result_model.g.dart';

@JsonSerializable()
class EventResultModel {
  num? id;
  String? name;
  String? image;
  num? correct_answers;
  num? points;

  EventResultModel({this.id, this.name, this.image, this.correct_answers, this.points});

  factory EventResultModel.fromJson(Map<String, dynamic> json) => _$EventResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventResultModelToJson(this);
}
