import 'package:json_annotation/json_annotation.dart';

part 'booking_available_response_model.g.dart';

@JsonSerializable()
class BookingAvailableResponseModel {
  final bool? available;

  BookingAvailableResponseModel({
    this.available,
  });

  factory BookingAvailableResponseModel.fromJson(Map<String, dynamic> json) => _$BookingAvailableResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingAvailableResponseModelToJson(this);
}
