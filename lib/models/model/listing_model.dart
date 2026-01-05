import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/model/users_model.dart';

class ListingModel {
  final Items item;
  final Users seller;
  final int sellerID;

  // Computed properties for convenience
  String get itemTitle => item.title;
  String get sellerName => seller.name;
  double get sellerRating => seller.reputationScore;
  double get itemPrice => item.price;
  String get itemCondition => item.condition;
  int get itemQuantity => item.quantity;
  String get itemStatus => item.status;
  ModerationStatus get moderationStatus => item.moderationStatus;
  int get itemViewCount => item.viewCount;
  int get itemFavoriteCount => item.favoriteCount;

  ListingModel({
    required this.item,
    required this.seller,
    required this.sellerID,
  }) {
    // Validate that sellerID matches the seller's userID
    assert(
      sellerID == seller.userID,
      'sellerID ($sellerID) must match seller.userID (${seller.userID})',
    );
  }

  /// Factory constructor to create a ListingModel from JSON
  factory ListingModel.fromJson(
    Map<String, dynamic> json,
    Items item,
    Users seller,
  ) {
    return ListingModel(
      item: item,
      seller: seller,
      sellerID: json['sellerID'] ?? seller.userID,
    );
  }

  /// Convert ListingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemID': item.itemID,
      'sellerID': sellerID,
      'item': item.toJson(),
      'seller': seller.toJson(),
    };
  }

  /// Create a copy with modified fields
  ListingModel copyWith({
    Items? item,
    Users? seller,
    int? sellerID,
  }) {
    return ListingModel(
      item: item ?? this.item,
      seller: seller ?? this.seller,
      sellerID: sellerID ?? this.sellerID,
    );
  }

  /// Get a display-friendly string representation
  @override
  String toString() {
    return 'ListingModel(itemID: ${item.itemID}, title: $itemTitle, seller: $sellerName, price: ₱$itemPrice)';
  }

  /// Check if the listing is available for purchase
  bool get isAvailable {
    return item.status == 'available' && 
           item.quantity > 0 && 
           item.moderationStatus == ModerationStatus.approved;
  }

  /// Check if the seller is active
  bool get isSellerActive {
    return seller.status.toString() == 'UserStatus.active';
  }
}