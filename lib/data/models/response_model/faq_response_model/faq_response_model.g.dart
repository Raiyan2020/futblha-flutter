// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqResponseModel _$FaqResponseModelFromJson(Map<String, dynamic> json) =>
    FaqResponseModel(
      id: (json['id'] as num?)?.toInt(),
      question: json['question'] as String?,
      answer: json['answer'] as String?,
      status: (json['status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$FaqResponseModelToJson(FaqResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'answer': instance.answer,
      'status': instance.status,
    };
