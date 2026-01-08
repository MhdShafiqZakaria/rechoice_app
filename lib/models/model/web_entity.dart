/// Model for web entities
class WebEntity {
  final String description;
  final double score;

  WebEntity({
    required this.description,
    required this.score,
  });

  factory WebEntity.fromJson(Map<String, dynamic> json) {
    return WebEntity(
      description: json['description'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}