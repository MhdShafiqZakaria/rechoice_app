/// Model for detected labels
class Label {
  final String name;
  final double confidence;
  final String description;

  Label({
    required this.name,
    required this.confidence,
    required this.description,
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      name: json['name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }
}