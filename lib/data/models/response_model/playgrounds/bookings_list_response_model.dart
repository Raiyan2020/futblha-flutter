import 'package:json_annotation/json_annotation.dart';
import 'booking_model.dart';

part 'bookings_list_response_model.g.dart';

@JsonSerializable()
class BookingsListResponseModel {
  final List<BookingModel>? data;

  BookingsListResponseModel({
    this.data,
  });

  factory BookingsListResponseModel.fromJson(Map<String, dynamic> json) => _$BookingsListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingsListResponseModelToJson(this);
}

