// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playground_detail_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaygroundDetailResponseModel _$PlaygroundDetailResponseModelFromJson(
  Map<String, dynamic> json,
) => PlaygroundDetailResponseModel(
  playground: json['playground'] == null
      ? null
      : PlaygroundModel.fromJson(json['playground'] as Map<String, dynamic>),
  availableSlots: (json['available_slots'] as List<dynamic>?)
      ?.map((e) => AvailableSlotModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlaygroundDetailResponseModelToJson(
  PlaygroundDetailResponseModel instance,
) => <String, dynamic>{
  'playground': instance.playground,
  'available_slots': instance.availableSlots,
};
