class JoinGameRequestModel {
  final String position; // e.g., "goal_keeper"
  final String? my_diwanya_team; // team_1 || team_2
  /// 0-based slot index within the team (when joining from empty slot on pitch).
  final int? slot_index;

  JoinGameRequestModel({
    required this.position,
    this.my_diwanya_team,
    this.slot_index,
  });

  Map<String, dynamic> toFormData() {
    final map = <String, dynamic>{
      'position': position,
      'my_diwanya_team': my_diwanya_team,
    };
    if (slot_index != null) map['slot_index'] = slot_index.toString();
    return map;
  }
}
