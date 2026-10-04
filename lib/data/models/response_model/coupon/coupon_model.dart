import 'package:json_annotation/json_annotation.dart';

part 'coupon_model.g.dart';

@JsonSerializable()
class CouponModel {
  final int? id;
  final String? code;
  final String? type; // e.g., percent, fixed
  final String? value; // e.g., "10.00"
  @JsonKey(name: 'max_discount')
  final String? maxDiscount;
  @JsonKey(name: 'usage_limit')
  final int? usageLimit;
  @JsonKey(name: 'used_count')
  final int? usedCount;
  @JsonKey(name: 'starts_at')
  final String? startsAt;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;
  final bool? status;

  CouponModel({
    this.id,
    this.code,
    this.type,
    this.value,
    this.maxDiscount,
    this.usageLimit,
    this.usedCount,
    this.startsAt,
    this.expiresAt,
    this.status,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) => _$CouponModelFromJson(json);
  Map<String, dynamic> toJson() => _$CouponModelToJson(this);
}


