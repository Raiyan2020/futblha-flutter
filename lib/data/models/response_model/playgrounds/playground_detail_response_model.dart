import 'package:json_annotation/json_annotation.dart';
import 'playground_model.dart';
import 'available_slot_model.dart';

part 'playground_detail_response_model.g.dart';

@JsonSerializable()
class PlaygroundDetailResponseModel {
  final PlaygroundModel? playground;
  @JsonKey(name: 'available_slots')
  final List<AvailableSlotModel>? availableSlots;

  PlaygroundDetailResponseModel({
    this.playground,
    this.availableSlots,
  });

  factory PlaygroundDetailResponseModel.fromJson(Map<String, dynamic> json) => _$PlaygroundDetailResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PlaygroundDetailResponseModelToJson(this);
}

