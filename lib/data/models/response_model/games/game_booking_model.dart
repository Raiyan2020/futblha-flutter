import 'package:json_annotation/json_annotation.dart';
import '../../../../application/core/utils/helpers/extension_functions/date_extension_functions.dart';
import '../playgrounds/playground_model.dart';
import '../playgrounds/booking_period_model.dart';

part 'game_booking_model.g.dart';

@JsonSerializable()
class GameBookingModel {
  final int? id;
  final String? code;
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'payment_method_text')
  final String? paymentMethodText;
  @JsonKey(name: 'total_hours')
  final int? totalHours;
  @JsonKey(name: 'hourly_rate')
  final String? hourlyRate;
  final String? total;
  @JsonKey(name: 'voucher_discount')
  final String? voucherDiscount;
  @JsonKey(name: 'wallet_discount')
  final String? walletDiscount;
  @JsonKey(name: 'grand_total')
  final String? grandTotal;
  @JsonKey(name: 'booking_date')
  @LocalizedDateConverter()
  final DateTime? bookingDate;
  final List<BookingPeriodModel>? periods;
  final PlaygroundModel? playground;

  GameBookingModel({
    this.id,
    this.code,
    this.paymentUrl,
    this.paymentMethod,
    this.paymentMethodText,
    this.totalHours,
    this.hourlyRate,
    this.total,
    this.voucherDiscount,
    this.walletDiscount,
    this.grandTotal,
    this.bookingDate,
    this.periods,
    this.playground,
  });

  factory GameBookingModel.fromJson(Map<String, dynamic> json) => _$GameBookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$GameBookingModelToJson(this);
}

