class CreateGameRequestModel {
  final int playgroundId;
  final String bookingDate; // Format: YYYY-MM-DD
  final List<GamePeriod> periods; // Array of {start_time, end_time}
  final String type; // public, private, my_diwanya
  final int players; // Number of players
  final String position; // Player position (e.g., "goal_keeper", "attacker", "defender", "center")
  final int? opponentDiwaniyaId; // Required if type is private
  final int? slotIndex; // Predicted slot index for creator (GK=0, defender=1, etc.)

  CreateGameRequestModel({
    required this.playgroundId,
    required this.bookingDate,
    required this.periods,
    required this.type,
    required this.players,
    required this.position,
    this.opponentDiwaniyaId,
    this.slotIndex,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {
      'playground_id': playgroundId.toString(),
      'booking_date': bookingDate,
      'type': type,
      'players': players.toString(),
      'position': position,
    };

    if (opponentDiwaniyaId != null) {
      formData['opponent_diwaniya_id'] = opponentDiwaniyaId.toString();
    }
    if (slotIndex != null) {
      formData['slot_index'] = slotIndex.toString();
    }

    // Add periods
    for (int i = 0; i < periods.length; i++) {
      formData['periods[$i][start_time]'] = periods[i].startTime;
      formData['periods[$i][end_time]'] = periods[i].endTime;
    }

    return formData;
  }
}

class GamePeriod {
  final String startTime; // Format: HH:mm
  final String endTime; // Format: HH:mm

  GamePeriod({required this.startTime, required this.endTime});
}
