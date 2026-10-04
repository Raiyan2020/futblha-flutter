import 'package:json_annotation/json_annotation.dart';

part 'package_model.g.dart';

@JsonSerializable()
class PackageModel {
  num? id;
  String? name;
  String? price;
  num? jewels;

  PackageModel({this.id, this.name, this.price, this.jewels});

  factory PackageModel.fromJson(Map<String, dynamic> json) => _$PackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PackageModelToJson(this);
}
