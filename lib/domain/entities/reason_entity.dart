import 'package:json_annotation/json_annotation.dart';

part 'reason_entity.g.dart';

@JsonSerializable()
class ReasonEntity {
  num? id;
  String? name;

  ReasonEntity({this.id, this.name});

  factory ReasonEntity.fromJson(Map<String, dynamic> json) => _$ReasonEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ReasonEntityToJson(this);
}
