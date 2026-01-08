import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rechoice_app/models/model/ai_recognition_result.dart';
import 'package:rechoice_app/services/ai_image_service.dart';
import 'dart:io';
import 'dart:async';

/// Modal dialog for AI image recognition
class AIRecognitionModal extends StatefulWidget {
  const AIRecognitionModal({super.key});

  @override
  State<AIRecognitionModal> createState() => _AIRecognitionModalState();
}

class _AIRecognitionModalState extends State<AIRecognitionModal> {
  late AIImageService _aiService;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  AIRecognitionResult? _results;
  String? _error;
  final String _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  StreamSubscription<AIRecognitionResult?>? _resultsSubscription;

  @override
  void initState() {
    super.initState();
    _aiService = AIImageService(userId: _userId);
  }

  @override
  void dispose() {
    _resultsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _results = null;
          _error = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _results = null;
          _error = null;
        });
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    }
  }

  Future<void> _recognizeImage() async {
    if (_selectedImage == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _resultsSubscription?.cancel();

      final imageId = await _aiService.uploadImage(_selectedImage!);
      if (imageId == null) {
        throw 'Failed to upload image';
      }

      _resultsSubscription = _aiService
          .watchResults(imageId)
          .listen(
            (results) {
              if (results != null && mounted) {
                setState(() {
                  _results = results;
                  _isLoading = false;
                });
                _resultsSubscription?.cancel();
              }
            },
            onError: (error) {
              if (mounted) {
                _showError('Error getting results: $error');
              }
              _resultsSubscription?.cancel();
            },
          );

      Future.delayed(const Duration(minutes: 2), () {
        if (_isLoading && mounted) {
          _showError('Processing timeout - try again later');
          _resultsSubscription?.cancel();
        }
      });
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.image_search, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'AI Image Recognition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[100],
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No image selected',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    if (_results == null && !_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    if (_isLoading)
                      Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          const Text(
                            'Processing image...',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else if (_results != null)
                      _buildResultsView()
                    else if (_selectedImage != null)
                      ElevatedButton.icon(
                        onPressed: _recognizeImage,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Recognize Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    if (_results == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '✓ Processed in ${_results!.processingTime.toStringAsFixed(2)}s',
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 12),

        if (_results!.labels.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Detection',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  _results!.labels[0].name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(_results!.labels[0].confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

        if (_results!.labels.length > 1) ...[
          const SizedBox(height: 12),
          const Text(
            'Other Labels:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ..._results!.labels
              .skip(1)
              .take(3)
              .map(
                (label) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label.name),
                      Chip(
                        label: Text(
                          '${(label.confidence * 100).toStringAsFixed(0)}%',
                        ),
                        backgroundColor: Colors.grey[200],
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
        ],

        if (_results!.objects.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Objects Detected:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ..._results!.objects
              .take(2)
              .map(
                (obj) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(obj.name),
                      Chip(
                        label: Text(
                          '${(obj.confidence * 100).toStringAsFixed(0)}%',
                        ),
                        backgroundColor: Colors.purple[200],
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
        ],

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedImage = null;
                _results = null;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Recognize Another Image'),
          ),
        ),
      ],
    );
  }
}
