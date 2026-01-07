import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/review/star_rating.dart';
import 'package:rechoice_app/models/model/review_model.dart';
import 'package:rechoice_app/models/viewmodels/review_view_model.dart';

class ReviewForm extends StatefulWidget {
  final int userID;
  final String customerName;
  final String customerAvatar;
  final int itemID;
  final String productName;
  final String? userUID;
  final VoidCallback? onSuccess;

  const ReviewForm({
    super.key,
    required this.userID,
    required this.customerName,
    required this.customerAvatar,
    required this.itemID,
    required this.productName,
    this.userUID,
    this.onSuccess,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final TextEditingController _contentController = TextEditingController();
  double _selectedRating = 0;
  bool _hasExistingReview = false;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    final viewModel = context.read<ReviewViewModel>();
    final existingReview = await viewModel.getUserReviewForItem(
      widget.userID,
      widget.itemID,
    );

    if (existingReview != null && mounted) {
      setState(() {
        _hasExistingReview = true;
      });
      _showSnackBar(
        'You have already reviewed this product',
        Colors.orange,
      );
    }
  }

  Future<void> _submitReview(ReviewViewModel viewModel) async {
    if (_selectedRating == 0) {
      _showSnackBar('Please select a rating', Colors.orange);
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      _showSnackBar('Please enter a review', Colors.orange);
      return;
    }

    final review = Review(
      id: '',
      userID: widget.userID,
      customerName: widget.customerName,
      customerAvatar: widget.customerAvatar,
      rating: _selectedRating,
      comment: _contentController.text.trim(),
      date: DateTime.now(),
      itemID: widget.itemID,
      productName: widget.productName,
      userUID: widget.userUID,
    );

    final reviewId = await viewModel.createReview(review);

    if (reviewId != null && mounted) {
      _showSnackBar('Review submitted successfully!', Colors.green);
      _resetForm();
      widget.onSuccess?.call();
    } else if (mounted) {
      _showSnackBar(
        viewModel.errorMessage ?? 'Failed to submit review',
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetForm() {
    _contentController.clear();
    setState(() {
      _selectedRating = 0;
    });
  }

  String _getRatingLabel(double rating) {
    if (rating == 0) return 'Rate your experience';
    if (rating <= 2) return 'Poor';
    if (rating <= 3) return 'Average';
    if (rating <= 4) return 'Good';
    return 'Excellent';
  }

  Color _getRatingColor(double rating) {
    if (rating == 0) return Colors.grey;
    if (rating <= 2) return Colors.red.shade600;
    if (rating <= 3) return Colors.orange.shade600;
    if (rating <= 4) return Colors.lightBlue.shade600;
    return Colors.green.shade600;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewViewModel>(
      builder: (context, viewModel, child) {
        if (_hasExistingReview) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.shade200,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade700,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Already Reviewed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You have already submitted a review for this product',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share Your Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your review helps others make informed decisions',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.shade100,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getRatingLabel(_selectedRating),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getRatingColor(_selectedRating),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rate your experience',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        if (_selectedRating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getRatingColor(_selectedRating),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${_selectedRating.toStringAsFixed(1)}/5',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StarRating(
                      initialRating: _selectedRating,
                      onRatingChanged: (rating) {
                        setState(() {
                          _selectedRating = rating;
                        });
                      },
                      starCount: 5,
                      size: 40,
                      isInteractive: true,
                      activeColor: Colors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Review',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLength: 500,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Share your detailed experience, pros, cons, and more...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue.shade600,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      counterStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: viewModel.isLoading 
                      ? null 
                      : () => _submitReview(viewModel),
                  icon: viewModel.isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Icon(Icons.check_circle_outline),
                  label: Text(
                    viewModel.isLoading ? 'Submitting...' : 'Submit Review'
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}