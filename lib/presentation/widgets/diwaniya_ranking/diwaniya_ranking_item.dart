class DiwaniyaRankingItem {
  final int? id;
  final int rank;
  final String name;
  final int points;
  final bool isMine;
  final String? imagePath;
  final String? backgroundImagePath;
  final double? containerHeight;

  const DiwaniyaRankingItem({
    this.id,
    required this.rank,
    required this.name,
    required this.points,
    this.isMine = false,
    this.imagePath,
    this.backgroundImagePath,
    this.containerHeight,
  });
}

