// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diwaniyas_overview_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiwaniyasOverviewResponseModel _$DiwaniyasOverviewResponseModelFromJson(
  Map<String, dynamic> json,
) => DiwaniyasOverviewResponseModel(
  myDiwaniya: json['my_diwaniya'] == null
      ? null
      : DiwaniyaModel.fromJson(json['my_diwaniya'] as Map<String, dynamic>),
  otherDiwaniyas: json['other_diwaniyas'] == null
      ? null
      : DiwaniyasListResponseModel.fromJson(
          json['other_diwaniyas'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DiwaniyasOverviewResponseModelToJson(
  DiwaniyasOverviewResponseModel instance,
) => <String, dynamic>{
  'my_diwaniya': instance.myDiwaniya,
  'other_diwaniyas': instance.otherDiwaniyas,
};
