//ITEM CLASS
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/category_model.dart';

enum ModerationStatus { pending, approved, rejected, flagged }

class Items {
  final int itemID;
  final String title;
  final ItemCategoryModel category;
  final String brand;
  final String condition;
  final double price;
  final int quantity;
  final String description;
  final String status; //available, sold out, removed
  final String imagePath;

  // Moderation fields
  final ModerationStatus moderationStatus;
  final DateTime postedDate;
  final int sellerID;
  final String? rejectionReason;
  final DateTime? moderatedDate;
  final int? moderatedBy;

  // Additional fields for better functionality
  final String? sellerName; // For display purposes
  final double? sellerRating; // For display purposes
  final int viewCount; // Track popularity
  final int favoriteCount; // Track wishlist adds

  const Items({
    required this.itemID,
    required this.title,
    required this.category,
    required this.brand,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.description,
    required this.status,
    required this.imagePath,
    this.moderationStatus = ModerationStatus.pending,
    required this.postedDate,
    required this.sellerID,
    this.rejectionReason,
    this.moderatedDate,
    this.moderatedBy,
    this.sellerName,
    this.sellerRating,
    this.viewCount = 0,
    this.favoriteCount = 0,
  });

  //Factory Method to create model instance from Json map

  factory Items.fromJson(Map<String, dynamic> json) {
    try {
      final postedTs = json['postedDate'];
      final moderatedTs = json['moderatedDate'];

      // Add prints before each major field
      final category = json['category'] != null
          ? ItemCategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : ItemCategoryModel.empty();

      final moderationStatus = ModerationStatus.values.firstWhere(
        (e) => e.toString() == 'ModerationStatus.${json['moderationStatus']}',
        orElse: () => ModerationStatus.pending,
      );


      // Safe conversion helper for int fields
      int? _toInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
        if (value is double) return value.toInt();
        return null;
      }

      final item = Items(
        itemID: _toInt(json['itemID']) ?? 0,
        title: json['title'] as String? ?? '',
        category: category,
        brand: json['brand'] as String? ?? '',
        condition: json['condition'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        quantity: _toInt(json['quantity']) ?? 0,
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? 'available',
        imagePath: json['image'] as String? ?? '',
        moderationStatus: moderationStatus,
        postedDate: postedTs is Timestamp ? postedTs.toDate() : DateTime.now(),
        sellerID: _toInt(json['sellerID']) ?? 0,
        rejectionReason: json['rejectionReason'] as String?,
        moderatedDate: moderatedTs is Timestamp ? moderatedTs.toDate() : null,
        moderatedBy: _toInt(json['moderatedBy']),
        sellerName: json['sellerName'] as String?,
        sellerRating: (json['sellerRating'] as num?)?.toDouble(),
        viewCount: _toInt(json['viewCount']) ?? 0,
        favoriteCount: _toInt(json['favoriteCount']) ?? 0,
      );
      return item;
    } catch (e) {
      rethrow; // Re-throw so it's caught in getItemsBySeller
    }
  }

  //Factory Method to convert model to Json structure for data storage in firebase

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'title': title,
      'category': category.toJson(),
      'brand': brand,
      'condition': condition,
      'price': price,
      'quantity': quantity,
      'description': description,
      'status': status,
      'image': imagePath,
      'moderationStatus': moderationStatus.toString().split('.').last,
      'postedDate': postedDate.toIso8601String(),
      'sellerID': sellerID,
      'rejectionReason': rejectionReason,
      'moderatedDate': moderatedDate?.toIso8601String(),
      'moderatedBy': moderatedBy,
      'sellerName': sellerName,
      'sellerRating': sellerRating,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
    };
  }

  // Helper methods for moderation
  bool get isPending => moderationStatus == ModerationStatus.pending;
  bool get isApproved => moderationStatus == ModerationStatus.approved;
  bool get isRejected => moderationStatus == ModerationStatus.rejected;
  bool get isFlagged => moderationStatus == ModerationStatus.flagged;
  // Item availability checks
  bool get isAvailable => status == 'available' && isApproved;
  bool get isSold => status == 'sold';
  bool get isRemoved => status == 'removed';
  bool get isInStock => quantity > 0;
  bool get isOutOfStock => quantity == 0;

  // Check if listing needs attention (pending or flagged)
  bool get needsAttention => isPending || isFlagged;

  // Get days since posted
  int get daysSincePosted => DateTime.now().difference(postedDate).inDays;

  // Check if item is new (posted within last 7 days)
  bool get isNew => daysSincePosted <= 7;

  // // Check if item has multiple images
  // bool get hasMultipleImages => imagePath.length > 1;

  bool get hasImage => imagePath.isNotEmpty;

  // Check if item is popular
  bool get isPopular => viewCount > 100 || favoriteCount > 20;
  // Get popularity score (based on views and favorites)
  double get popularityScore => (viewCount * 0.6) + (favoriteCount * 0.4);

  // Copy with method (useful for updating moderation status)
  Items copyWith({
    int? itemID,
    String? title,
    ItemCategoryModel? category,
    String? brand,
    String? condition,
    double? price,
    int? quantity,
    String? description,
    String? status,
    String? imagePath,
    ModerationStatus? moderationStatus,
    DateTime? postedDate,
    int? sellerID,
    String? rejectionReason,
    DateTime? moderatedDate,
    int? moderatedBy,
    String? sellerName,
    double? sellerRating,
    int? viewCount,
    int? favoriteCount,
  }) {
    return Items(
      itemID: itemID ?? this.itemID,
      title: title ?? this.title,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      postedDate: postedDate ?? this.postedDate,
      sellerID: sellerID ?? this.sellerID,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      moderatedDate: moderatedDate ?? this.moderatedDate,
      moderatedBy: moderatedBy ?? this.moderatedBy,
      sellerName: sellerName ?? this.sellerName,
      sellerRating: sellerRating ?? this.sellerRating,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }
}
