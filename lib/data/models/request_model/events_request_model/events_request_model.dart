import 'package:json_annotation/json_annotation.dart';

part 'events_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class EventsRequestModel {
  num? event_id;
  num? question_id;
  String? answer;

  EventsRequestModel({this.event_id, this.question_id, this.answer});

  factory EventsRequestModel.fromJson(Map<String, dynamic> json) => _$EventsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventsRequestModelToJson(this);
}
