import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/generated/locale_keys.g.dart';

/// Enum representing all available player positions
enum Position {
  attacker('attacker'),
  center('center'),
  defender('defender'),
  goalKeeper('goal_keeper'),
  jocker('jocker');

  const Position(this.key);

  final String key;

  /// Get the localized display name for the position
  String get displayName {
    switch (this) {
      case Position.attacker:
        return LocaleKeys.position_attacker.tr();
      case Position.center:
        return LocaleKeys.position_center.tr();
      case Position.defender:
        return LocaleKeys.position_defender.tr();
      case Position.goalKeeper:
        return LocaleKeys.position_goalkeeper.tr();
      case Position.jocker:
        return LocaleKeys.jocker_all_positions.tr();
    }
  }

  /// Get all positions except jocker (for selection lists)
  static List<Position> get selectablePositions => [
    Position.attacker,
    Position.center,
    Position.defender,
    Position.goalKeeper,
  ];

  /// Get all positions including jocker
  static List<Position> get allPositions => Position.values;

  /// Convert a string key to Position enum
  static Position? fromKey(String? key) {
    if (key == null) return null;
    try {
      return Position.values.firstWhere((position) => position.key == key);
    } catch (e) {
      return null;
    }
  }

  /// Convert a list of string keys to Position enums
  static List<Position> fromKeys(List<String>? keys) {
    if (keys == null || keys.isEmpty) return [];
    return keys.map((key) => Position.fromKey(key)).whereType<Position>().toList();
  }

  /// Convert Position enum to string key (for API)
  static List<String> toKeys(List<Position> positions) {
    return positions.map((position) => position.key).toList();
  }

  /// Check if a position string matches this enum (handles various formats)
  bool matches(String? positionString) {
    if (positionString == null) return false;
    final pos = positionString.toLowerCase();

    switch (this) {
      case Position.goalKeeper:
        return pos == 'goalkeeper' || pos == 'goal_keeper' || pos == 'gk' || pos == key;
      case Position.defender:
        return pos == 'defender' ||
            pos == 'defence' ||
            pos == 'defense' ||
            pos == 'def' ||
            pos == key;
      case Position.center:
        return pos == 'midfielder' || pos == 'center' || pos == 'mid' || pos == key;
      case Position.attacker:
        return pos == 'attacker' ||
            pos == 'forward' ||
            pos == 'striker' ||
            pos == 'fwd' ||
            pos == key;
      case Position.jocker:
        return pos == 'jocker' || pos == key;
    }
  }

  /// Get position type for field positioning (goalkeeper, defender, midfielder, forward)
  String get positionType {
    switch (this) {
      case Position.goalKeeper:
        return 'goalkeeper';
      case Position.defender:
        return 'defender';
      case Position.center:
        return 'midfielder';
      case Position.attacker:
        return 'forward';
      case Position.jocker:
        return 'midfielder'; // Default for jocker
    }
  }
}
