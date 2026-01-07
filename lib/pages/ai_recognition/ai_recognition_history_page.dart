import 'package:flutter/material.dart';
import '../../services/ai_image_service.dart';

/// AI Image History Page
/// Shows user's previous image recognition results
class AIRecognitionHistoryPage extends StatefulWidget {
  final String userId;

  const AIRecognitionHistoryPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AIRecognitionHistoryPage> createState() =>
      _AIRecognitionHistoryPageState();
}

class _AIRecognitionHistoryPageState extends State<AIRecognitionHistoryPage> {
  late AIImageService _aiService;
  List<ImageHistory> _images = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _aiService = AIImageService(userId: widget.userId);
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      final images = await _aiService.getUserImages();
      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load images: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await _aiService.deleteImage(imageId);
      if (success) {
        setState(() {
          _images.removeWhere((img) => img.imageId == imageId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognition History'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadImages,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadImages,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _images.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No images yet'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        final image = _images[index];
                        return _buildImageCard(image);
                      },
                    ),
    );
  }

  Widget _buildImageCard(ImageHistory image) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.filename,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(image.timestamp),
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(image.status),
              ],
            ),
            const SizedBox(height: 12),
            if (image.status == 'completed' && image.topLabel != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.label, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Label',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            image.topLabel!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (image.confidence != null)
                      Chip(
                        label: Text(
                          '${(image.confidence! * 100).toStringAsFixed(0)}%',
                        ),
                        backgroundColor: Colors.blue[200],
                        labelStyle: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDetails(image),
                    icon: const Icon(Icons.info, size: 18),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _deleteImage(image.imageId),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'completed':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        displayText = 'Done';
        break;
      case 'processing':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[700]!;
        displayText = 'Processing';
        break;
      case 'error':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        displayText = 'Error';
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
        displayText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _showDetails(ImageHistory image) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Image ID', image.imageId),
              _buildDetailRow('Filename', image.filename),
              _buildDetailRow('Status', image.status),
              _buildDetailRow('Date', _formatDate(image.timestamp)),
              if (image.topLabel != null)
                _buildDetailRow('Top Label', image.topLabel!),
              if (image.confidence != null)
                _buildDetailRow(
                  'Confidence',
                  '${(image.confidence! * 100).toStringAsFixed(1)}%',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          SelectableText(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
