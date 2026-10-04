// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionsResponseModel _$TransactionsResponseModelFromJson(
  Map<String, dynamic> json,
) => TransactionsResponseModel(
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  balance: json['balance'],
);

Map<String, dynamic> _$TransactionsResponseModelToJson(
  TransactionsResponseModel instance,
) => <String, dynamic>{'data': instance.data, 'balance': instance.balance};
