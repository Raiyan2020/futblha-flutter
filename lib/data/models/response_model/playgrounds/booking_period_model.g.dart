// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_period_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingPeriodModel _$BookingPeriodModelFromJson(Map<String, dynamic> json) =>
    BookingPeriodModel(
      id: (json['id'] as num?)?.toInt(),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );

Map<String, dynamic> _$BookingPeriodModelToJson(BookingPeriodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };
