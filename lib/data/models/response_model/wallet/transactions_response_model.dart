import 'package:json_annotation/json_annotation.dart';
import 'transaction_model.dart';

part 'transactions_response_model.g.dart';

@JsonSerializable()
class TransactionsResponseModel {
  final List<TransactionModel>? data;
  final dynamic balance;

  TransactionsResponseModel({
    this.data,
    this.balance,
  });

  factory TransactionsResponseModel.fromJson(Map<String, dynamic> json) => _$TransactionsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionsResponseModelToJson(this);
}

