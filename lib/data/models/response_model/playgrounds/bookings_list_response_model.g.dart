// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookings_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingsListResponseModel _$BookingsListResponseModelFromJson(
  Map<String, dynamic> json,
) => BookingsListResponseModel(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookingsListResponseModelToJson(
  BookingsListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
