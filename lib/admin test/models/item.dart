// models/item.dart

enum ModerationStatus {
  pending,
  approved,
  rejected,
  flagged,
}

class Item {
  final int itemID;
  final String title;
  final Category category;
  final String brand;
  final String condition;
  final double price;
  final int quantity;
  final String description;
  final String status; // available, sold, removed
  final List<String> images;
  
  // NEW: Moderation fields
  final ModerationStatus moderationStatus;
  final DateTime postedDate;
  final int sellerID; // Who posted this item
  final String? rejectionReason; // If rejected, why?
  final DateTime? moderatedDate; // When was it approved/rejected
  final int? moderatedBy; // Admin who moderated (adminID)

  Item({
    required this.itemID,
    required this.title,
    required this.category,
    required this.brand,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.description,
    required this.status,
    required this.images,
    this.moderationStatus = ModerationStatus.pending,
    required this.postedDate,
    required this.sellerID,
    this.rejectionReason,
    this.moderatedDate,
    this.moderatedBy,
  });

  // Firebase ready - fromJson
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemID: json['itemID'],
      title: json['title'],
      category: Category.fromJson(json['category']),
      brand: json['brand'],
      condition: json['condition'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      description: json['description'],
      status: json['status'],
      images: List<String>.from(json['images']),
      moderationStatus: ModerationStatus.values.firstWhere(
        (e) => e.toString() == 'ModerationStatus.${json['moderationStatus']}',
        orElse: () => ModerationStatus.pending,
      ),
      postedDate: DateTime.parse(json['postedDate']),
      sellerID: json['sellerID'],
      rejectionReason: json['rejectionReason'],
      moderatedDate: json['moderatedDate'] != null 
          ? DateTime.parse(json['moderatedDate']) 
          : null,
      moderatedBy: json['moderatedBy'],
    );
  }

  // Firebase ready - toJson
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
      'images': images,
      'moderationStatus': moderationStatus.toString().split('.').last,
      'postedDate': postedDate.toIso8601String(),
      'sellerID': sellerID,
      'rejectionReason': rejectionReason,
      'moderatedDate': moderatedDate?.toIso8601String(),
      'moderatedBy': moderatedBy,
    };
  }

  // Helper methods for moderation
  bool get isPending => moderationStatus == ModerationStatus.pending;
  bool get isApproved => moderationStatus == ModerationStatus.approved;
  bool get isRejected => moderationStatus == ModerationStatus.rejected;
  bool get isFlagged => moderationStatus == ModerationStatus.flagged;

  // Get status text
  String get moderationStatusText {
    switch (moderationStatus) {
      case ModerationStatus.pending:
        return 'pending';
      case ModerationStatus.approved:
        return 'approved';
      case ModerationStatus.rejected:
        return 'rejected';
      case ModerationStatus.flagged:
        return 'flagged';
    }
  }

  // Get status color
  String get moderationStatusColor {
    switch (moderationStatus) {
      case ModerationStatus.pending:
        return 'orange';
      case ModerationStatus.approved:
        return 'green';
      case ModerationStatus.rejected:
        return 'red';
      case ModerationStatus.flagged:
        return 'red';
    }
  }

  // Get formatted posted date
  String get formattedPostedDate {
    return '${postedDate.year}-${postedDate.month.toString().padLeft(2, '0')}-${postedDate.day.toString().padLeft(2, '0')}';
  }

  // Get formatted moderated date
  String get formattedModeratedDate {
    if (moderatedDate == null) return 'N/A';
    return '${moderatedDate!.year}-${moderatedDate!.month.toString().padLeft(2, '0')}-${moderatedDate!.day.toString().padLeft(2, '0')}';
  }

  // Check if listing needs attention (pending or flagged)
  bool get needsAttention {
    return isPending || isFlagged;
  }

  // Get days since posted
  int get daysSincePosted {
    return DateTime.now().difference(postedDate).inDays;
  }

  // Check if item is new (posted within last 7 days)
  bool get isNew => daysSincePosted <= 7;

  // Format price
  String get formattedPrice => 'RM${price.toStringAsFixed(0)}';

  // Copy with method (useful for updating moderation status)
  Item copyWith({
    int? itemID,
    String? title,
    Category? category,
    String? brand,
    String? condition,
    double? price,
    int? quantity,
    String? description,
    String? status,
    List<String>? images,
    ModerationStatus? moderationStatus,
    DateTime? postedDate,
    int? sellerID,
    String? rejectionReason,
    DateTime? moderatedDate,
    int? moderatedBy,
  }) {
    return Item(
      itemID: itemID ?? this.itemID,
      title: title ?? this.title,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      status: status ?? this.status,
      images: images ?? this.images,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      postedDate: postedDate ?? this.postedDate,
      sellerID: sellerID ?? this.sellerID,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      moderatedDate: moderatedDate ?? this.moderatedDate,
      moderatedBy: moderatedBy ?? this.moderatedBy,
    );
  }

  // Helper method to approve item
  Item approve(int adminID) {
    return copyWith(
      moderationStatus: ModerationStatus.approved,
      moderatedDate: DateTime.now(),
      moderatedBy: adminID,
      rejectionReason: null,
    );
  }

  // Helper method to reject item
  Item reject(int adminID, String reason) {
    return copyWith(
      moderationStatus: ModerationStatus.rejected,
      moderatedDate: DateTime.now(),
      moderatedBy: adminID,
      rejectionReason: reason,
    );
  }

  // Helper method to flag item
  Item flag(int adminID, String reason) {
    return copyWith(
      moderationStatus: ModerationStatus.flagged,
      moderatedDate: DateTime.now(),
      moderatedBy: adminID,
      rejectionReason: reason,
    );
  }
}

// Extension for list operations (admin screens)
extension ItemListExtension on List<Item> {
  List<Item> get pendingItems => where((i) => i.isPending).toList();
  List<Item> get approvedItems => where((i) => i.isApproved).toList();
  List<Item> get rejectedItems => where((i) => i.isRejected).toList();
  List<Item> get flaggedItems => where((i) => i.isFlagged).toList();
  List<Item> get needsAttentionItems => where((i) => i.needsAttention).toList();
  
  int get totalPending => pendingItems.length;
  int get totalApproved => approvedItems.length;
  int get totalRejected => rejectedItems.length;
  int get totalFlagged => flaggedItems.length;

  // Sort by posted date (newest first)
  List<Item> get byNewest {
    final sorted = List<Item>.from(this);
    sorted.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return sorted;
  }

  // Filter by seller
  List<Item> bySeller(int sellerID) {
    return where((i) => i.sellerID == sellerID).toList();
  }

  // Filter by category
  List<Item> byCategory(int categoryID) {
    return where((i) => i.category.categoryID == categoryID).toList();
  }
}

// Category model (keeping it here for reference, same as before)
class Category {
  final int categoryID;
  final String name;
  final String iconName;

  Category({
    required this.categoryID,
    required this.name,
    required this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryID: json['categoryID'],
      name: json['name'],
      iconName: json['iconName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryID': categoryID,
      'name': name,
      'iconName': iconName,
    };
  }
}