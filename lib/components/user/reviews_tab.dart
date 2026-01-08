import 'package:flutter/material.dart';
import 'package:rechoice_app/components/review/review_card.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/model/review_model.dart';

class ReviewsTab extends StatefulWidget {
  final Users user;

  const ReviewsTab({super.key, required this.user});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  late List<Review> _reviews;
  Map<String, dynamic>? _analytics;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _initializeDummyReviews();
    _calculateAnalytics();
  }

  void _initializeDummyReviews() {
    _reviews = [
      Review(
        id: '1',
        userID: 101,
        customerName: 'Sarah Martinez',
        customerAvatar: '',
        rating: 5.0,
        comment: 'Great seller! Fast delivery and excellent condition. The item arrived exactly as described. The seller provided great communication throughout the process. Highly recommended!',
        date: DateTime.now().subtract(const Duration(days: 2)),
        itemID: 1001,
        productName: 'Vintage Leather Jacket',
        userUID: 'user_101',
      ),
      Review(
        id: '2',
        userID: 102,
        customerName: 'Ahmad Rahman',
        customerAvatar: '',
        rating: 4.0,
        comment: 'Product was in good condition. Fair pricing and responsive seller. Would buy again.',
        date: DateTime.now().subtract(const Duration(days: 7)),
        itemID: 1002,
        productName: 'Designer Handbag',
        userUID: 'user_102',
      ),
      Review(
        id: '3',
        userID: 103,
        customerName: 'Maria Lopez',
        customerAvatar: '',
        rating: 5.0,
        comment: 'Perfect! Exactly what I was looking for. The item quality exceeded my expectations. Fast shipping and excellent packaging. Very happy with this purchase!',
        date: DateTime.now().subtract(const Duration(days: 14)),
        itemID: 1003,
        productName: 'Running Shoes',
        userUID: 'user_103',
      ),
      Review(
        id: '4',
        userID: 104,
        customerName: 'John Chen',
        customerAvatar: '',
        rating: 4.5,
        comment: 'Excellent service and product quality. Seller was very accommodating and answered all my questions promptly.',
        date: DateTime.now().subtract(const Duration(days: 21)),
        itemID: 1004,
        productName: 'Bluetooth Headphones',
        userUID: 'user_104',
      ),
      Review(
        id: '5',
        userID: 105,
        customerName: 'Emma Thompson',
        customerAvatar: '',
        rating: 3.5,
        comment: 'Item was okay, but had some minor wear that wasn\'t mentioned in the description. Still functional though.',
        date: DateTime.now().subtract(const Duration(days: 28)),
        itemID: 1005,
        productName: 'Laptop Stand',
        userUID: 'user_105',
      ),
      Review(
        id: '6',
        userID: 106,
        customerName: 'David Kim',
        customerAvatar: '',
        rating: 5.0,
        comment: 'Outstanding seller! Item came well-packaged and was exactly as advertised. Will definitely purchase from this seller again.',
        date: DateTime.now().subtract(const Duration(days: 35)),
        itemID: 1006,
        productName: 'Desk Organizer',
        userUID: 'user_106',
      ),
    ];
  }

  void _calculateAnalytics() {
    if (_reviews.isNotEmpty) {
      _analytics = {
        'totalReviews': _reviews.length,
        'averageRating': _reviews.averageRating,
        'positivePercentage': _reviews.positivePercentage,
        'ratingDistribution': _reviews.ratingDistribution,
        'positiveCount': _reviews.positiveCount,
        'negativeCount': _reviews.negativeCount,
        'neutralCount': _reviews.neutralCount,
      };
    }
  }

  List<Review> _getSortedReviews(List<Review> reviews) {
    switch (_sortBy) {
      case 'newest':
        return reviews.sortedByNewest;
      case 'oldest':
        final sorted = List<Review>.from(reviews);
        sorted.sort((a, b) => a.date.compareTo(b.date));
        return sorted;
      case 'highest':
        return reviews.sortedByRating;
      case 'lowest':
        final sorted = List<Review>.from(reviews);
        sorted.sort((a, b) => a.rating.compareTo(b.rating));
        return sorted;
      default:
        return reviews;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedReviews = _getSortedReviews(_reviews);

    if (_reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final averageRating = _analytics?['averageRating'] ?? 
        widget.user.reputationScore;
    final totalReviews = _analytics?['totalReviews'] ?? _reviews.length;
    final ratingDistribution = _analytics?['ratingDistribution'] ?? 
        {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _initializeDummyReviews();
          _calculateAnalytics();
        });
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Summary Card
            Container(
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
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Overall Rating
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final starValue = index + 1;
                                if (averageRating >= starValue) {
                                  return Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                } else if (averageRating >= starValue - 0.5) {
                                  return Icon(
                                    Icons.star_half,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                } else {
                                  return Icon(
                                    Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Based on $totalReviews review${totalReviews != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right side - Rating Bars
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: List.generate(5, (index) {
                            final stars = 5 - index;
                            final count = ratingDistribution[stars] ?? 0;
                            return Column(
                              children: [
                                if (index > 0) SizedBox(height: 8),
                                _RatingBar(
                                  stars: stars,
                                  count: count,
                                  total: totalReviews,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sort and Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Reviews',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: Container(),
                  items: [
                    DropdownMenuItem(
                      value: 'newest',
                      child: Text('Newest'),
                    ),
                    DropdownMenuItem(
                      value: 'oldest',
                      child: Text('Oldest'),
                    ),
                    DropdownMenuItem(
                      value: 'highest',
                      child: Text('Highest'),
                    ),
                    DropdownMenuItem(
                      value: 'lowest',
                      child: Text('Lowest'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Review Cards
            ...sortedReviews.map((review) {
              return Column(
                children: [
                  ReviewCard(
                    review: review,
                    helpfulCount: (review.rating * 3).round(),
                    showProductName: true,
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Rating Bar Widget
class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // Background bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Filled bar
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          child: Text(
            '$count',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}