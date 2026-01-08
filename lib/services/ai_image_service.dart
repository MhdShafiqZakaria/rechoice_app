import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:rechoice_app/models/model/ai_recognition_result.dart';
import 'package:rechoice_app/models/model/image_history_model.dart';

class AIImageService {
  final String userId;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  AIImageService({required this.userId});

  /// Upload image and trigger AI processing
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Generate unique image ID
      final imageId = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'images/$userId/$imageId.jpg';

      print('📤 Uploading to Firebase Storage: $fileName');

      // Upload to Cloud Storage
      final ref = _storage.ref().child(fileName);
      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      print('✓ Upload complete: $imageUrl');

      // Create metadata in Firestore
      await _firestore.collection('images').doc(imageId).set({
        'imageId': imageId,
        'userId': userId,
        'filename': fileName,
        'imageUrl': imageUrl,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Trigger Cloud Function for AI processing
      print('🤖 Triggering AI processing...');
      await _functions.httpsCallable('processImage').call({
        'imageId': imageId,
        'imageUrl': imageUrl,
      });

      return imageId;
    } catch (e) {
      print('✗ Upload error: $e');
      return null;
    }
  }

  /// Get AI recognition results from Firestore
  Future<AIRecognitionResult?> getResults(String imageId) async {
    try {
      final doc = await _firestore.collection('images').doc(imageId).get();
      
      if (!doc.exists) {
        print('✗ Image not found: $imageId');
        return null;
      }

      final data = doc.data()!;
      final status = data['status'];

      if (status == 'completed' && data['results'] != null) {
        print('✓ Results ready for $imageId');
        return AIRecognitionResult.fromJson(data['results']);
      } else if (status == 'processing' || status == 'pending') {
        print('⏳ Still processing $imageId');
        return null;
      } else {
        print('✗ Processing failed: $imageId');
        return null;
      }
    } catch (e) {
      print('✗ Get results error: $e');
      return null;
    }
  }

  /// Listen to results in real-time (better than polling)
  Stream<AIRecognitionResult?> watchResults(String imageId) {
    return _firestore.collection('images').doc(imageId).snapshots().map((doc) {
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      if (data['status'] == 'completed' && data['results'] != null) {
        return AIRecognitionResult.fromJson(data['results']);
      }
      return null;
    });
  }

  /// Get user's image history
  Future<List<ImageHistory>> getUserImages() async {
    try {
      final snapshot = await _firestore
          .collection('images')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ImageHistory.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('✗ Error getting images: $e');
      return [];
    }
  }

  /// Delete image
  Future<bool> deleteImage(String imageId) async {
    try {
      // Delete from Firestore
      await _firestore.collection('images').doc(imageId).delete();
      
      // Delete from Storage
      final doc = await _firestore.collection('images').doc(imageId).get();
      if (doc.exists) {
        final fileName = doc.data()!['filename'];
        await _storage.ref().child(fileName).delete();
      }

      print('✓ Image deleted: $imageId');
      return true;
    } catch (e) {
      print('✗ Delete error: $e');
      return false;
    }
  }
}