// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'available_slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableSlotModel _$AvailableSlotModelFromJson(Map<String, dynamic> json) =>
    AvailableSlotModel(
      startAt: json['start_at'] as String?,
      endAt: json['end_at'] as String?,
      available: json['available'] as bool?,
    );

Map<String, dynamic> _$AvailableSlotModelToJson(AvailableSlotModel instance) =>
    <String, dynamic>{
      'start_at': instance.startAt,
      'end_at': instance.endAt,
      'available': instance.available,
    };
