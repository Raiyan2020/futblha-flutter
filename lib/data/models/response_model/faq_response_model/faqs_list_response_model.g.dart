// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faqs_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqsListResponseModel _$FaqsListResponseModelFromJson(
  Map<String, dynamic> json,
) => FaqsListResponseModel(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => FaqResponseModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$FaqsListResponseModelToJson(
  FaqsListResponseModel instance,
) => <String, dynamic>{'data': instance.data};
