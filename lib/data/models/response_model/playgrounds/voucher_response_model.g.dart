// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoucherResponseModel _$VoucherResponseModelFromJson(
  Map<String, dynamic> json,
) => VoucherResponseModel(
  id: (json['id'] as num?)?.toInt(),
  code: json['code'] as String?,
  discount: json['discount'] as String?,
  startAt: json['start_at'] as String?,
  endAt: json['end_at'] as String?,
);

Map<String, dynamic> _$VoucherResponseModelToJson(
  VoucherResponseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'discount': instance.discount,
  'start_at': instance.startAt,
  'end_at': instance.endAt,
};
