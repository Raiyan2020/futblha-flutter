import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {
  final int? id;
  final String? amount;
  final String? type;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final String? notes;

  TransactionModel({
    this.id,
    this.amount,
    this.type,
    this.createdAt,
    this.notes,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);
}

