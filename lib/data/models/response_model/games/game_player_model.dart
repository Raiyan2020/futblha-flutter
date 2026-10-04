import 'package:json_annotation/json_annotation.dart';

part 'game_player_model.g.dart';

@JsonSerializable()
class GamePlayerModel {
  final int? id;
  final String? name;
  final String? image;
  final String? position;
  @JsonKey(name: 'position_text')
  final String? positionText;
  @JsonKey(name: 'slot_index')
  final String? slotIndex;
  @JsonKey(name: 'team_index')
  final int? teamIndex;

  GamePlayerModel({
    this.id,
    this.name,
    this.image,
    this.position,
    this.positionText,
    this.slotIndex,
    this.teamIndex,
  });

  factory GamePlayerModel.fromJson(Map<String, dynamic> json) => _$GamePlayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$GamePlayerModelToJson(this);

  GamePlayerModel copyWith({int? slotIndex, int? teamIndex}) {
    return GamePlayerModel(
      id: id,
      name: name,
      image: image,
      position: position,
      positionText: positionText,
      slotIndex: (slotIndex ?? this.slotIndex).toString(),
      teamIndex: teamIndex ?? this.teamIndex,
    );
  }
}
