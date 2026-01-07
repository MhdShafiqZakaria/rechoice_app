import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final int userID; // Reference to Users model
  final String customerName;
  final String customerAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final int itemID; // Reference to Items model
  final String productName;
  
  // Optional: Store user UID for Firebase auth integration
  final String? userUID;

  Review({
    required this.id,
    required this.userID,
    required this.customerName,
    required this.customerAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    required this.itemID,
    required this.productName,
    this.userUID,
  });

  // Factory method to create from JSON/Firestore
  factory Review.fromJson(Map<String, dynamic> json) {
    final dateTs = json['date'];
    
    return Review(
      id: json['id'] as String? ?? '',
      userID: json['userID'] as int? ?? 0,
      customerName: json['customerName'] as String? ?? '',
      customerAvatar: json['customerAvatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      date: dateTs is Timestamp ? dateTs.toDate() : DateTime.now(),
      itemID: json['itemID'] as int? ?? 0,
      productName: json['productName'] as String? ?? '',
      userUID: json['userUID'] as String?,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userID': userID,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
      'itemID': itemID,
      'productName': productName,
      'userUID': userUID,
    };
  }

  // Helper methods
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(date);
    return difference.inDays <= 7;
  }

  bool get isPositive => rating >= 4.0;
  bool get isNegative => rating <= 2.0;
  bool get isNeutral => rating > 2.0 && rating < 4.0;

  String get ratingLabel {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    return 'Poor';
  }

  // Copy with method for updates
  Review copyWith({
    String? id,
    int? userID,
    String? customerName,
    String? customerAvatar,
    double? rating,
    String? comment,
    DateTime? date,
    int? itemID,
    String? productName,
    String? userUID,
  }) {
    return Review(
      id: id ?? this.id,
      userID: userID ?? this.userID,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      itemID: itemID ?? this.itemID,
      productName: productName ?? this.productName,
      userUID: userUID ?? this.userUID,
    );
  }
}

// Extension methods for review lists
extension ReviewListExtension on List<Review> {
  // Get average rating
  double get averageRating {
    if (isEmpty) return 0.0;
    return fold<double>(0, (sum, review) => sum + review.rating) / length;
  }

  // Get rating distribution
  Map<int, int> get ratingDistribution {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in this) {
      final roundedRating = review.rating.round();
      distribution[roundedRating] = (distribution[roundedRating] ?? 0) + 1;
    }
    return distribution;
  }

  // Filter methods
  List<Review> get recentReviews => where((r) => r.isRecent).toList();
  List<Review> get positiveReviews => where((r) => r.isPositive).toList();
  List<Review> get negativeReviews => where((r) => r.isNegative).toList();
  List<Review> get neutralReviews => where((r) => r.isNeutral).toList();

  // Get reviews by user
  List<Review> byUser(int userID) => 
      where((r) => r.userID == userID).toList();

  // Get reviews for item
  List<Review> forItem(int itemID) => 
      where((r) => r.itemID == itemID).toList();

  // Sort methods
  List<Review> get sortedByNewest {
    final sorted = List<Review>.from(this);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<Review> get sortedByRating {
    final sorted = List<Review>.from(this);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  // Statistics
  int get totalReviews => length;
  int get positiveCount => positiveReviews.length;
  int get negativeCount => negativeReviews.length;
  int get neutralCount => neutralReviews.length;

  double get positivePercentage => 
      isEmpty ? 0.0 : (positiveCount / length) * 100;
}