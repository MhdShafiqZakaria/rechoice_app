import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

/// AI Image Recognition Service
/// Communicates with the Node.js backend for image recognition
class AIImageService {
  // Backend API base URL
  // Change to your actual backend URL in production
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // For physical device: 'http://192.168.x.x:3000/api'
  // For iOS simulator: 'http://localhost:3000/api'

  final String userId;

  AIImageService({required this.userId});

  /// Upload image and start AI recognition
  /// Returns imageId to track progress
  Future<String?> uploadImage(File imageFile) async {
    try {
      print('📤 Uploading image: ${imageFile.path}');
      print('📤 Image size: ${imageFile.lengthSync()} bytes');
      print('📤 Backend URL: $baseUrl/images/upload');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/images/upload'),
      );

      // Determine MIME type based on file extension
      String getMimeType(String filePath) {
        if (filePath.toLowerCase().endsWith('.png')) {
          return 'image/png';
        } else if (filePath.toLowerCase().endsWith('.webp')) {
          return 'image/webp';
        } else {
          return 'image/jpeg'; // default to JPEG
        }
      }

      final mimeType = getMimeType(imageFile.path);
      print('📤 Image MIME type: $mimeType');

      // Add image file with explicit MIME type
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: http.MediaType.parse(mimeType),
        ),
      );

      // Add userId
      request.fields['userId'] = userId;
      
      print('📤 Sending request to backend...');

      // Send request with timeout
      var response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('❌ Request timeout after 30 seconds');
          throw Exception('Upload timeout');
        },
      );

      print('📤 Response status: ${response.statusCode}');
      final responseBody = await response.stream.bytesToString();
      print('📤 Response body: $responseBody');

      if (response.statusCode == 202) {
        // 202 = Accepted (processing started)
        final responseData = jsonDecode(responseBody);
        final imageId = responseData['imageId'];
        print('✓ Image uploaded: $imageId');
        return imageId;
      } else {
        print('✗ Upload failed with status: ${response.statusCode}');
        print('✗ Response: $responseBody');
        return null;
      }
    } catch (e) {
      print('✗ Upload error: $e');
      print('✗ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Get AI recognition results
  /// Returns null if still processing, or results when ready
  Future<AIRecognitionResult?> getResults(String imageId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/images/$imageId/results'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Results ready
        final data = jsonDecode(response.body);
        print('✓ Results received for $imageId');
        return AIRecognitionResult.fromJson(data['results']);
      } else if (response.statusCode == 202) {
        // Still processing
        print('⏳ Still processing $imageId');
        return null;
      } else if (response.statusCode == 404) {
        print('✗ Image not found: $imageId');
        return null;
      } else {
        print('✗ Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('✗ Get results error: $e');
      return null;
    }
  }

  /// Poll for results with retry logic
  /// Polls up to 60 times with 2 second delay (2 minutes total)
  /// Google Vision API can take 5-15 seconds per image
  Future<AIRecognitionResult?> waitForResults(
    String imageId, {
    int maxRetries = 60,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxRetries; i++) {
      final result = await getResults(imageId);
      if (result != null) {
        return result;
      }
      if (i < maxRetries - 1) {
        print('⏳ Waiting... (${i + 1}/$maxRetries)');
        await Future.delayed(retryDelay);
      }
    }
    return null;
  }

  /// Get user's image history
  Future<List<ImageHistory>> getUserImages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/images'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final images = (data['images'] as List)
            .map((img) => ImageHistory.fromJson(img))
            .toList();
        print('✓ Got ${images.length} images');
        return images;
      }
      return [];
    } catch (e) {
      print('✗ Error getting images: $e');
      return [];
    }
  }

  /// Delete image
  Future<bool> deleteImage(String imageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/images/$imageId?userId=$userId'),
      );

      if (response.statusCode == 200) {
        print('✓ Image deleted: $imageId');
        return true;
      }
      return false;
    } catch (e) {
      print('✗ Delete error: $e');
      return false;
    }
  }
}

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

/// Model for dominant colors
class DominantColor {
  final String hex;
  final int pixelFraction;

  DominantColor({
    required this.hex,
    required this.pixelFraction,
  });

  factory DominantColor.fromJson(Map<String, dynamic> json) {
    return DominantColor(
      hex: json['hex'] ?? '#000000',
      pixelFraction: json['pixelFraction'] ?? 0,
    );
  }
}

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
