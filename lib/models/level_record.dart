// =============================================================================
// LEVEL RECORD MODEL
// =============================================================================

/// Stores the best score and star rating for a single level.
class LevelRecord {
  int stars;
  int score;

  LevelRecord({this.stars = 0, this.score = 0});

  Map<String, dynamic> toJson() => {'stars': stars, 'score': score};

  factory LevelRecord.fromJson(Map<String, dynamic> json) => LevelRecord(
        stars: json['stars'] as int? ?? 0,
        score: json['score'] as int? ?? 0,
      );
}