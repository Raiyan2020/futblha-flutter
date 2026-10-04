import 'package:json_annotation/json_annotation.dart';
import 'booking_model.dart';

part 'booking_response_model.g.dart';

@JsonSerializable()
class BookingResponseModel {
  final BookingModel? data;

  BookingResponseModel({
    this.data,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) => _$BookingResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingResponseModelToJson(this);
}

