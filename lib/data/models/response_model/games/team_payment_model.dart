import 'package:json_annotation/json_annotation.dart';

part 'team_payment_model.g.dart';

/// One Diwaniya's share of a private game's booking.
@JsonSerializable()
class TeamPaymentModel {
  final String? team; // host | opponent
  @JsonKey(name: 'diwaniya_id')
  final int? diwaniyaId;
  final String? amount;
  final String? status; // unpaid | pending | paid | failed | refunded
  @JsonKey(name: 'paid_at')
  final String? paidAt;

  TeamPaymentModel({this.team, this.diwaniyaId, this.amount, this.status, this.paidAt});

  factory TeamPaymentModel.fromJson(Map<String, dynamic> json) => _$TeamPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeamPaymentModelToJson(this);
}
