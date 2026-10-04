// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: (json['id'] as num?)?.toInt(),
  code: json['code'] as String?,
  paymentUrl: json['payment_url'] as String?,
  paymentMethod: json['payment_method'] as String?,
  paymentMethodText: json['payment_method_text'] as String?,
  totalHours: (json['total_hours'] as num?)?.toInt(),
  hourlyRate: json['hourly_rate'] as String?,
  total: json['total'] as String?,
  voucherDiscount: json['voucher_discount'] as String?,
  walletDiscount: json['wallet_discount'] as String?,
  grandTotal: json['grand_total'] as String?,
  bookingDate: json['booking_date'] as String?,
  periods: (json['periods'] as List<dynamic>?)
      ?.map((e) => BookingPeriodModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  playground: json['playground'] == null
      ? null
      : PlaygroundModel.fromJson(json['playground'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'payment_url': instance.paymentUrl,
      'payment_method': instance.paymentMethod,
      'payment_method_text': instance.paymentMethodText,
      'total_hours': instance.totalHours,
      'hourly_rate': instance.hourlyRate,
      'total': instance.total,
      'voucher_discount': instance.voucherDiscount,
      'wallet_discount': instance.walletDiscount,
      'grand_total': instance.grandTotal,
      'booking_date': instance.bookingDate,
      'periods': instance.periods,
      'playground': instance.playground,
    };
