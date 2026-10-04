import 'package:futblha/data/models/response_model/games/game_player_model.dart';

/// Sort order for displaying players on the playground: GK -> Defender -> Center -> Attacker
int gamePositionSortOrder(String? position) {
  if (position == null) return 4;
  final p = position.toLowerCase();
  if (p == 'goal_keeper' || p == 'goalkeeper' || p == 'gk') return 0;
  if (p == 'defender' || p == 'defence' || p == 'defense' || p == 'def') return 1;
  if (p == 'center' || p == 'midfielder' || p == 'mid') return 2;
  if (p == 'attacker' || p == 'forward' || p == 'striker' || p == 'fwd') return 3;
  if (p == 'jocker') return 2;
  return 4;
}

/// Returns a copy of the list sorted by position for playground display order.
List<GamePlayerModel> sortPlayersByPosition(List<GamePlayerModel> players) {
  final list = List<GamePlayerModel>.from(players);
  list.sort(
    (a, b) => gamePositionSortOrder(a.position).compareTo(gamePositionSortOrder(b.position)),
  );
  return list;
}

/// Generates the "rows" for the team (GK - Def - Mid - Fwd).
/// Index 0 is always the Goalkeeper. The last index is the Forward line.
List<int> generateFormationStructure(int count) {
  if (count <= 0) return [];
  if (count == 1) return [1];

  if (count == 11) return [1, 4, 3, 3];
  if (count == 10) return [1, 4, 3, 2];
  if (count == 9) return [1, 3, 3, 2];
  if (count == 8) return [1, 3, 2, 2];
  if (count == 7) return [1, 3, 2, 1];
  if (count == 6) return [1, 2, 2, 1];
  if (count == 5) return [1, 2, 1, 1];
  if (count == 4) return [1, 1, 2];
  if (count == 3) return [1, 2];

  int fieldPlayers = count - 1;
  int def = (fieldPlayers * 0.4).ceil();
  int mid = (fieldPlayers * 0.35).round();
  int fwd = fieldPlayers - def - mid;
  if (fwd == 0 && mid > 0) {
    mid--;
    fwd++;
  }
  return [1, def, mid, fwd].where((n) => n > 0).toList();
}

/// Positions for small formations (2v2–11v11).
Map<String, double> getSmallFormationPosition(int teamIndex, int playerIndex, int playersPerTeam) {
  final formation = generateFormationStructure(playersPerTeam);

  int rowForPlayer = 0;
  int positionInRow = 0;
  int countProcessed = 0;

  for (int i = 0; i < formation.length; i++) {
    int countInThisRow = formation[i];
    if (playerIndex < countProcessed + countInThisRow) {
      rowForPlayer = i;
      positionInRow = playerIndex - countProcessed;
      break;
    }
    countProcessed += countInThisRow;
  }

  final isTopTeam = teamIndex == 0;
  final int playersInThisRow = formation[rowForPlayer];
  final double x = (positionInRow + 1) / (playersInThisRow + 1);

  final double startY = isTopTeam ? 0.08 : 0.92;
  final double endY = isTopTeam ? 0.44 : 0.56;
  final int totalRows = formation.length > 1 ? formation.length - 1 : 1;
  final double depthProgress = rowForPlayer / totalRows;
  final double y = startY + (endY - startY) * depthProgress;

  return {'x': x, 'y': y};
}

/// Simple distribution for larger formations (12+).
Map<String, double> getSimpleDistribution(int teamIndex, int playerIndex, int playersPerTeam) {
  final isTopTeam = teamIndex == 0;
  final baseY = isTopTeam ? 0.1 : 0.9;
  final yRange = isTopTeam ? 0.3 : -0.3;

  final cols = (playersPerTeam <= 6)
      ? 3
      : (playersPerTeam <= 12)
      ? 4
      : 5;
  final rows = (playersPerTeam / cols).ceil();

  final col = playerIndex % cols;
  final row = (playerIndex / cols).floor();

  const xMargin = 0.15;
  final xRange = 1.0 - (2 * xMargin);
  final xDivisor = (cols > 1) ? (cols - 1) : 1;
  final x = xMargin + (col / xDivisor) * xRange;

  final yDivisor = (rows > 1) ? (rows - 1) : 1;
  final y = baseY + (row / yDivisor) * yRange;

  return {'x': x.clamp(0.1, 0.9), 'y': y.clamp(0.1, 0.9)};
}

/// Returns field coordinates for a player/slot. teamIndex: 0 = top, 1 = bottom.
Map<String, double> getPositionCoordinates(
  int teamIndex,
  int playerIndexInTeam,
  int playersPerTeam,
) {
  if (playersPerTeam == 0) return {};
  if (playersPerTeam <= 11) {
    return getSmallFormationPosition(teamIndex, playerIndexInTeam, playersPerTeam);
  }
  return getSimpleDistribution(teamIndex, playerIndexInTeam, playersPerTeam);
}

/// Returns the slot index for a given position based on formation (GK=0, defender=1, etc.).
/// Use when joining from Join Game page or creating a game to send predicted slot_index.
int getSlotIndexForPosition(String positionKey, int playersPerTeam) {
  if (playersPerTeam <= 0) return 0;
  final formation = generateFormationStructure(playersPerTeam);
  if (formation.isEmpty) return 0;

  final order = gamePositionSortOrder(positionKey);
  if (order <= 0) return 0;
  if (order >= formation.length) return (formation.length - 1).clamp(0, playersPerTeam - 1);

  int start = 0;
  for (int i = 0; i < order; i++) {
    start += formation[i];
  }
  return start.clamp(0, playersPerTeam - 1);
}

/// Position keys for formation rows: 0=GK, 1=def, 2=center, 3=attacker.
const List<String> _positionKeysByRow = ['goal_keeper', 'defender', 'center', 'attacker'];

/// Returns the position key for a given slot index (same mapping as formation rows).
String getPositionKeyForSlotIndex(int slotIndex, int playersPerTeam) {
  if (playersPerTeam <= 0) return 'center';
  final formation = generateFormationStructure(playersPerTeam);
  if (formation.isEmpty) return 'center';

  int count = 0;
  for (int row = 0; row < formation.length; row++) {
    count += formation[row];
    if (slotIndex < count) {
      final keyIndex = row.clamp(0, _positionKeysByRow.length - 1);
      return _positionKeysByRow[keyIndex];
    }
  }
  return _positionKeysByRow[(formation.length - 1).clamp(0, _positionKeysByRow.length - 1)];
}

/// Returns the first empty slot for the given position, avoiding [usedSlotIndices].
/// Prefers slots in the same formation row as the position; if all are used, returns first empty slot anywhere.
int getFirstEmptySlotForPosition(
  String positionKey,
  int playersPerTeam,
  Set<int> usedSlotIndices,
) {
  if (playersPerTeam <= 0) return 0;
  final formation = generateFormationStructure(playersPerTeam);
  if (formation.isEmpty) return 0;

  final order = gamePositionSortOrder(positionKey).clamp(0, formation.length - 1);
  int start = 0;
  for (int i = 0; i < order; i++) {
    start += formation[i];
  }
  final count = formation[order];
  final end = (start + count).clamp(0, playersPerTeam);

  for (int i = start; i < end; i++) {
    if (!usedSlotIndices.contains(i)) return i;
  }
  for (int i = 0; i < playersPerTeam; i++) {
    if (!usedSlotIndices.contains(i)) return i;
  }
  return start.clamp(0, playersPerTeam - 1);
}

/// Returns true if the position's formation row has at least one slot not in [usedSlotIndices].
bool hasEmptySlotForPosition(
  String positionKey,
  int playersPerTeam,
  Set<int> usedSlotIndices,
) {
  if (playersPerTeam <= 0) return false;
  final formation = generateFormationStructure(playersPerTeam);
  if (formation.isEmpty) return false;
  final order = gamePositionSortOrder(positionKey).clamp(0, formation.length - 1);
  int start = 0;
  for (int i = 0; i < order; i++) {
    start += formation[i];
  }
  final count = formation[order];
  final end = (start + count).clamp(0, playersPerTeam);
  for (int i = start; i < end; i++) {
    if (!usedSlotIndices.contains(i)) return true;
  }
  return false;
}
