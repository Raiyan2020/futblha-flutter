import 'package:json_annotation/json_annotation.dart';
import 'facility_model.dart';
import 'playground_image_model.dart';

part 'playground_model.g.dart';

@JsonSerializable()
class PlaygroundModel {
  final int? id;
  final String? name;
  final String? image;
  final String? price;
  final String? city;
  final dynamic rate;
  final String? lat;
  final String? lng;
  @JsonKey(name: 'land_type')
  final String? landType;
  final String? capacity;
  final String? description;
  final List<FacilityModel>? facilities;
  final List<PlaygroundImageModel>? images;

  PlaygroundModel({
    this.id,
    this.name,
    this.image,
    this.price,
    this.city,
    this.rate,
    this.lat,
    this.lng,
    this.landType,
    this.capacity,
    this.description,
    this.facilities,
    this.images,
  });

  factory PlaygroundModel.fromJson(Map<String, dynamic> json) => _$PlaygroundModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaygroundModelToJson(this);
}

