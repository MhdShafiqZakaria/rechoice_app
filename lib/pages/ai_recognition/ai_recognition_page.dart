import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/ai_image_service.dart';

/// AI Image Recognition Page
/// Main screen for image upload and AI recognition results
class AIRecognitionPage extends StatefulWidget {
  final String userId;

  const AIRecognitionPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AIRecognitionPage> createState() => _AIRecognitionPageState();
}

class _AIRecognitionPageState extends State<AIRecognitionPage> {
  late AIImageService _aiService;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  String? _currentImageId;
  AIRecognitionResult? _results;
  String? _error;

  @override
  void initState() {
    super.initState();
    _aiService = AIImageService(userId: widget.userId);
  }

  /// Pick image from gallery
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

  /// Take photo with camera
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

  /// Upload and recognize image
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
      // Step 1: Upload image
      final imageId = await _aiService.uploadImage(_selectedImage!);
      if (imageId == null) {
        throw 'Failed to upload image';
      }

      setState(() => _currentImageId = imageId);

      // Step 2: Wait for results
      final results = await _aiService.waitForResults(imageId);
      if (results == null) {
        throw 'Processing timeout - try again later';
      }

      setState(() {
        _results = results;
        _isLoading = false;
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Image Recognition'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              _buildImagePreview(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),

              // Results
              if (_isLoading)
                _buildLoadingState()
              else if (_results != null)
                _buildResultsView()
              else if (_selectedImage != null)
                _buildUploadPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build image preview
  Widget _buildImagePreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: _selectedImage != null
          ? Image.file(_selectedImage!, fit: BoxFit.cover)
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No image selected',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _takePhoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Camera'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            disabledBackgroundColor: Colors.grey,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _pickImage,
          icon: const Icon(Icons.image_search),
          label: const Text('Gallery'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            disabledBackgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// Build upload prompt
  Widget _buildUploadPrompt() {
    return ElevatedButton.icon(
      onPressed: _recognizeImage,
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Recognize Image'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text(
          'Processing image...',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        if (_currentImageId != null) ...[
          const SizedBox(height: 8),
          Text(
            'Image ID: $_currentImageId',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  /// Build results view
  Widget _buildResultsView() {
    if (_results == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Processing time
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Processing time: ${_results!.processingTime.toStringAsFixed(2)}s',
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 16),

        // Labels
        _buildSection(
          title: 'Detected Labels',
          icon: Icons.label,
          child: _results!.labels.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _results!.labels.length,
                  itemBuilder: (context, index) {
                    final label = _results!.labels[index];
                    return _buildLabelTile(label);
                  },
                )
              : const Text('No labels detected'),
        ),
        const SizedBox(height: 16),

        // Objects
        if (_results!.objects.isNotEmpty) ...[
          _buildSection(
            title: 'Detected Objects',
            icon: Icons.shapes,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results!.objects.length,
              itemBuilder: (context, index) {
                final obj = _results!.objects[index];
                return _buildObjectTile(obj);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Colors
        if (_results!.colors.isNotEmpty) ...[
          _buildSection(
            title: 'Dominant Colors',
            icon: Icons.palette,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _results!.colors
                    .map((color) => _buildColorChip(color))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Faces
        if (_results!.faces > 0) ...[
          _buildSection(
            title: 'Faces',
            icon: Icons.face,
            child: Text('${_results!.faces} face(s) detected'),
          ),
          const SizedBox(height: 16),
        ],

        // Web Entities
        if (_results!.webEntities.isNotEmpty) ...[
          _buildSection(
            title: 'Similar on Web',
            icon: Icons.language,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _results!.webEntities.length,
              itemBuilder: (context, index) {
                final entity = _results!.webEntities[index];
                return _buildWebEntityTile(entity);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // OCR Text
        if (_results!.text.isNotEmpty) ...[
          _buildSection(
            title: 'Text Detected',
            icon: Icons.text_fields,
            child: SelectableText(_results!.text),
          ),
        ],
      ],
    );
  }

  /// Build section header
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /// Build label tile
  Widget _buildLabelTile(Label label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: label.confidence,
                minHeight: 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  label.confidence > 0.8
                      ? Colors.green
                      : label.confidence > 0.6
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Confidence: ${(label.confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Build object tile
  Widget _buildObjectTile(ObjectDetection obj) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          border: Border.all(color: Colors.purple[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(obj.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Chip(
              label: Text('${(obj.confidence * 100).toStringAsFixed(1)}%'),
              backgroundColor: Colors.purple[200],
            ),
          ],
        ),
      ),
    );
  }

  /// Build color chip
  Widget _buildColorChip(Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _hexToColor(color.hex),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            color.hex,
            style: const TextStyle(fontSize: 11),
          ),
          Text(
            '${color.pixelFraction}%',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build web entity tile
  Widget _buildWebEntityTile(WebEntity entity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          border: Border.all(color: Colors.amber[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entity.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Chip(
              label: Text('${(entity.score * 100).toStringAsFixed(0)}%'),
              backgroundColor: Colors.amber[200],
            ),
          ],
        ),
      ),
    );
  }

  /// Convert hex color to Flutter Color
  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse(hex, radix: 16) | 0xFF000000);
  }
}
