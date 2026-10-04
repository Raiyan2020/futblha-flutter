import 'package:json_annotation/json_annotation.dart';
import 'playground_model.dart';
import 'booking_period_model.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel {
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
  final String? bookingDate;
  final List<BookingPeriodModel>? periods;
  final PlaygroundModel? playground;

  BookingModel({
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

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);
}

