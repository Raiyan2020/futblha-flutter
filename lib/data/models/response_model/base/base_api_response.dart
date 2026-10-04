import 'package:json_annotation/json_annotation.dart';

part 'base_api_response.g.dart';

@JsonSerializable()
class StatusAPI {
  num? code;
  num? subCode;
  String? message;

  StatusAPI({this.code, this.subCode, this.message});

  factory StatusAPI.fromJson(Map<String, dynamic> json) => _$StatusAPIFromJson(json);

  Map<String, dynamic> toJson() => _$StatusAPIToJson(this);
}
