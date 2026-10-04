import 'package:json_annotation/json_annotation.dart';

part 'playground_image_model.g.dart';

@JsonSerializable()
class PlaygroundImageModel {
  final int? id;
  final String? url;

  PlaygroundImageModel({
    this.id,
    this.url,
  });

  factory PlaygroundImageModel.fromJson(Map<String, dynamic> json) => _$PlaygroundImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaygroundImageModelToJson(this);
}

