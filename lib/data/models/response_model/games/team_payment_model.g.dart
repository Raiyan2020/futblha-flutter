// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamPaymentModel _$TeamPaymentModelFromJson(Map<String, dynamic> json) =>
    TeamPaymentModel(
      team: json['team'] as String?,
      diwaniyaId: (json['diwaniya_id'] as num?)?.toInt(),
      amount: json['amount'] as String?,
      status: json['status'] as String?,
      paidAt: json['paid_at'] as String?,
    );

Map<String, dynamic> _$TeamPaymentModelToJson(TeamPaymentModel instance) =>
    <String, dynamic>{
      'team': instance.team,
      'diwaniya_id': instance.diwaniyaId,
      'amount': instance.amount,
      'status': instance.status,
      'paid_at': instance.paidAt,
    };
