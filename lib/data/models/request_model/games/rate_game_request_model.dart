class RateGameRequestModel {
  final int levelRating;
  final int cleanGameRating;

  RateGameRequestModel({required this.levelRating, required this.cleanGameRating});

  Map<String, dynamic> toFormData() {
    return {
      'level_rating': levelRating.toString(),
      'clean_game_rating': cleanGameRating.toString(),
    };
  }
}
