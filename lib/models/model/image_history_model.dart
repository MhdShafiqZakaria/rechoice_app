/// Model for image history
class ImageHistory {
  final String imageId;
  final String filename;
  final DateTime timestamp;
  final String status;
  final String? topLabel;
  final double? confidence;

  ImageHistory({
    required this.imageId,
    required this.filename,
    required this.timestamp,
    required this.status,
    this.topLabel,
    this.confidence,
  });

  factory ImageHistory.fromJson(Map<String, dynamic> json) {
    return ImageHistory(
      imageId: json['imageId'] ?? '',
      filename: json['filename'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
      status: json['status'] ?? 'pending',
      topLabel: json['topLabel'],
      confidence: (json['confidence'] ?? 0).toDouble(),
    );
  }
}