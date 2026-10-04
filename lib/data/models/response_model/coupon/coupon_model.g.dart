// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouponModel _$CouponModelFromJson(Map<String, dynamic> json) => CouponModel(
  id: (json['id'] as num?)?.toInt(),
  code: json['code'] as String?,
  type: json['type'] as String?,
  value: json['value'] as String?,
  maxDiscount: json['max_discount'] as String?,
  usageLimit: (json['usage_limit'] as num?)?.toInt(),
  usedCount: (json['used_count'] as num?)?.toInt(),
  startsAt: json['starts_at'] as String?,
  expiresAt: json['expires_at'] as String?,
  status: json['status'] as bool?,
);

Map<String, dynamic> _$CouponModelToJson(CouponModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'type': instance.type,
      'value': instance.value,
      'max_discount': instance.maxDiscount,
      'usage_limit': instance.usageLimit,
      'used_count': instance.usedCount,
      'starts_at': instance.startsAt,
      'expires_at': instance.expiresAt,
      'status': instance.status,
    };
