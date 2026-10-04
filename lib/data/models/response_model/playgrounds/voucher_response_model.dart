import 'package:json_annotation/json_annotation.dart';

part 'voucher_response_model.g.dart';

@JsonSerializable()
class VoucherResponseModel {
  final int? id;
  final String? code;
  final String? discount;
  @JsonKey(name: 'start_at')
  final String? startAt;
  @JsonKey(name: 'end_at')
  final String? endAt;

  VoucherResponseModel({
    this.id,
    this.code,
    this.discount,
    this.startAt,
    this.endAt,
  });

  factory VoucherResponseModel.fromJson(Map<String, dynamic> json) => _$VoucherResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VoucherResponseModelToJson(this);
}

