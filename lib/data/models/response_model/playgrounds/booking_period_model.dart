import 'package:json_annotation/json_annotation.dart';

part 'booking_period_model.g.dart';

@JsonSerializable()
class BookingPeriodModel {
  final int? id;
  @JsonKey(name: 'start_time')
  final String? startTime;
  @JsonKey(name: 'end_time')
  final String? endTime;

  BookingPeriodModel({
    this.id,
    this.startTime,
    this.endTime,
  });

  factory BookingPeriodModel.fromJson(Map<String, dynamic> json) => _$BookingPeriodModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingPeriodModelToJson(this);
}

