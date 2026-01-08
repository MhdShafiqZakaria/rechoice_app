import 'package:rechoice_app/models/model/dominant_color_model.dart';
import 'package:rechoice_app/models/model/label.dart';
import 'package:rechoice_app/models/model/object_detection_model.dart';
import 'package:rechoice_app/models/model/web_entity.dart';

/// Model for AI Recognition Results
class AIRecognitionResult {
  final List<Label> labels;
  final List<ObjectDetection> objects;
  final List<DominantColor> colors;
  final int faces;
  final String text;
  final List<WebEntity> webEntities;
  final double processingTime;

  AIRecognitionResult({
    required this.labels,
    required this.objects,
    required this.colors,
    required this.faces,
    required this.text,
    required this.webEntities,
    required this.processingTime,
  });

  factory AIRecognitionResult.fromJson(Map<String, dynamic> json) {
    return AIRecognitionResult(
      labels: (json['labels'] as List?)
              ?.map((l) => Label.fromJson(l))
              .toList() ??
          [],
      objects: (json['objects'] as List?)
              ?.map((o) => ObjectDetection.fromJson(o))
              .toList() ??
          [],
      colors: (json['colors'] as List?)
              ?.map((c) => DominantColor.fromJson(c))
              .toList() ??
          [],
      faces: json['faces'] ?? 0,
      text: json['text'] ?? '',
      webEntities: (json['webEntities'] as List?)
              ?.map((e) => WebEntity.fromJson(e))
              .toList() ??
          [],
      processingTime: (json['processingTime'] ?? 0).toDouble(),
    );
  }
}