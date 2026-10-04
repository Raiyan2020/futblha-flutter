import 'package:json_annotation/json_annotation.dart';

part 'available_slot_model.g.dart';

@JsonSerializable()
class AvailableSlotModel {
  @JsonKey(name: 'start_at')
  final String? startAt;
  @JsonKey(name: 'end_at')
  final String? endAt;
  final bool? available;

  AvailableSlotModel({this.startAt, this.endAt, this.available});

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) =>
      _$AvailableSlotModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableSlotModelToJson(this);
}
