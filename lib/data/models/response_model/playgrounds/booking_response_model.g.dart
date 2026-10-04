// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingResponseModel _$BookingResponseModelFromJson(
  Map<String, dynamic> json,
) => BookingResponseModel(
  data: json['data'] == null
      ? null
      : BookingModel.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingResponseModelToJson(
  BookingResponseModel instance,
) => <String, dynamic>{'data': instance.data};
