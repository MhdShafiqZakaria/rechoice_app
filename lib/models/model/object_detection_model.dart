/// Model for detected objects
class ObjectDetection {
  final String name;
  final double confidence;

  ObjectDetection({
    required this.name,
    required this.confidence,
  });

  factory ObjectDetection.fromJson(Map<String, dynamic> json) {
    return ObjectDetection(
      name: json['name'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}