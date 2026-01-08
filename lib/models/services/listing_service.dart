import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/model/listing_model.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';
import 'package:rechoice_app/models/services/item_service.dart';

class ListingService {
  final FirestoreService _firestoreService;
  final ItemService _itemService;

  ListingService(this._firestoreService, this._itemService);

  CollectionReference get _itemsCollection =>
      _firestoreService.firestoreInstance.collection('items');

  CollectionReference get _usersCollection =>
      _firestoreService.firestoreInstance.collection('users');

  // ==================== FETCH ALL LISTINGS ====================

  /// Fetch all listings with seller information
  Future<List<ListingModel>> getAllListings() async {
    try {
      print('DEBUG: Fetching all listings');
      final itemSnapshot = await _itemsCollection.get();

      if (itemSnapshot.docs.isEmpty) {
        print('DEBUG: No items found');
        return [];
      }

      List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          // Fetch seller information
          final sellerDoc = await _usersCollection
              .where('userID', isEqualTo: item.sellerID)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData =
                sellerDoc.docs.first.data() as Map<String, dynamic>;
            final seller = Users.fromJson(sellerData);

            listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          print('DEBUG: Error processing item ${itemDoc.id}: $e');
          continue;
        }
      }

      print('DEBUG: Fetched ${listings.length} listings');
      return listings;
    } catch (e) {
      throw Exception('Failed to fetch all listings: $e');
    }
  }

  // ==================== FETCH APPROVED LISTINGS ====================

  /// Fetch only approved and available listings
  Future<List<ListingModel>> getApprovedListings() async {
    try {
      print('DEBUG: Fetching approved listings');
      final itemSnapshot = await _itemsCollection
          .where('moderationStatus', isEqualTo: 'approved')
          .where('status', isEqualTo: 'available')
          .get();

      if (itemSnapshot.docs.isEmpty) {
        print('DEBUG: No approved listings found');
        return [];
      }

      List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          // Fetch seller information
          final sellerDoc = await _usersCollection
              .where('userID', isEqualTo: item.sellerID)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData =
                sellerDoc.docs.first.data() as Map<String, dynamic>;
            final seller = Users.fromJson(sellerData);

            listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          print('DEBUG: Error processing approved item ${itemDoc.id}: $e');
          continue;
        }
      }

      print('DEBUG: Fetched ${listings.length} approved listings');
      return listings;
    } catch (e) {
      throw Exception('Failed to fetch approved listings: $e');
    }
  }

  // ==================== FETCH SELLER LISTINGS ====================

  /// Fetch listings for a specific seller
  Future<List<ListingModel>> getSellerListings(int sellerID) async {
    try {
      print('DEBUG: Fetching listings for seller $sellerID');

      // Fetch seller information
      final sellerDoc = await _usersCollection
          .where('userID', isEqualTo: sellerID)
          .limit(1)
          .get();

      if (sellerDoc.docs.isEmpty) {
        print('DEBUG: Seller not found');
        throw Exception('Seller not found');
      }

      final sellerData = sellerDoc.docs.first.data() as Map<String, dynamic>;
      final seller = Users.fromJson(sellerData);

      // Fetch seller's items
      final itemSnapshot = await _itemsCollection
          .where('sellerID', isEqualTo: sellerID)
          .get();

      List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          listings.add(
            ListingModel(item: item, seller: seller, sellerID: sellerID),
          );
        } catch (e) {
          print('DEBUG: Error processing seller item ${itemDoc.id}: $e');
          continue;
        }
      }

      print('DEBUG: Fetched ${listings.length} listings for seller $sellerID');
      return listings;
    } catch (e) {
      throw Exception('Failed to fetch seller listings: $e');
    }
  }

  // ==================== FETCH BY CATEGORY ====================

  /// Fetch listings by category
  Future<List<ListingModel>> getListingsByCategory(int categoryId) async {
    try {
      print('DEBUG: Fetching listings for category $categoryId');
      final itemSnapshot = await _itemsCollection
          .where('category.categoryID', isEqualTo: categoryId)
          .where('status', isEqualTo: 'available')
          .get();

      if (itemSnapshot.docs.isEmpty) {
        print('DEBUG: No listings found for category $categoryId');
        return [];
      }

      List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          // Fetch seller information
          final sellerDoc = await _usersCollection
              .where('userID', isEqualTo: item.sellerID)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData =
                sellerDoc.docs.first.data() as Map<String, dynamic>;
            final seller = Users.fromJson(sellerData);

            listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          print('DEBUG: Error processing category item ${itemDoc.id}: $e');
          continue;
        }
      }

      print(
        'DEBUG: Fetched ${listings.length} listings for category $categoryId',
      );
      return listings;
    } catch (e) {
      throw Exception('Failed to fetch category listings: $e');
    }
  }

  // ==================== SEARCH LISTINGS ====================

  /// Search listings by title or description
  Future<List<ListingModel>> searchListings(String query) async {
    try {
      print('DEBUG: Searching listings with query: $query');

      // Fetch all items and filter locally (Firestore text search limitation)
      final itemSnapshot = await _itemsCollection
          .where('status', isEqualTo: 'available')
          .get();

      final List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          // Check if title or description matches query
          final titleMatch = item.title.toLowerCase().contains(
            query.toLowerCase(),
          );
          final descriptionMatch = item.description.toLowerCase().contains(
            query.toLowerCase(),
          );

          if (!titleMatch && !descriptionMatch) continue;

          // Fetch seller information
          final sellerDoc = await _usersCollection
              .where('userID', isEqualTo: item.sellerID)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData =
                sellerDoc.docs.first.data() as Map<String, dynamic>;
            final seller = Users.fromJson(sellerData);

            listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          print('DEBUG: Error processing search result ${itemDoc.id}: $e');
          continue;
        }
      }

      print(
        'DEBUG: Found ${listings.length} matching listings for query: $query',
      );
      return listings;
    } catch (e) {
      throw Exception('Failed to search listings: $e');
    }
  }

  // ==================== FETCH BY PRICE RANGE ====================

  /// Fetch listings within a price range
  Future<List<ListingModel>> getListingsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      print('DEBUG: Fetching listings in price range ₱$minPrice - ₱$maxPrice');
      final itemSnapshot = await _itemsCollection
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .where('status', isEqualTo: 'available')
          .get();

      if (itemSnapshot.docs.isEmpty) {
        print('DEBUG: No listings found in price range');
        return [];
      }

      List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          // Fetch seller information
          final sellerDoc = await _usersCollection
              .where('userID', isEqualTo: item.sellerID)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData =
                sellerDoc.docs.first.data() as Map<String, dynamic>;
            final seller = Users.fromJson(sellerData);

            listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          print('DEBUG: Error processing price range item ${itemDoc.id}: $e');
          continue;
        }
      }

      print('DEBUG: Fetched ${listings.length} listings in price range');
      return listings;
    } catch (e) {
      throw Exception('Failed to fetch listings by price range: $e');
    }
  }

  // ==================== FETCH BY CONDITION ====================

  /// Fetch listings by condition (New, Like New, Good, Fair)
  Future<List<ListingModel>> getListingsByCondition(String condition) async {
    try {
      print('DEBUG: Fetching listings with condition: $condition');
      final itemSnapshot = await _itemsCollection
          .where('condition', isEqualTo: condition)
          .where('status', isEqualTo: 'available')
          .get();

      if (itemSnapshot.docs.isEmpty) {
        print('DEBUG: No listings found with condition $condition');
        return [];
      }

      List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          // Fetch seller information
          final sellerDoc = await _usersCollection
              .where('userID', isEqualTo: item.sellerID)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData =
                sellerDoc.docs.first.data() as Map<String, dynamic>;
            final seller = Users.fromJson(sellerData);

            listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          print('DEBUG: Error processing condition item ${itemDoc.id}: $e');
          continue;
        }
      }

      print(
        'DEBUG: Fetched ${listings.length} listings with condition $condition',
      );
      return listings;
    } catch (e) {
      throw Exception('Failed to fetch listings by condition: $e');
    }
  }

  // ==================== FETCH POPULAR LISTINGS ====================

  /// Fetch popular listings (sorted by view count)
  Future<List<ListingModel>> getPopularListings({int limit = 10}) async {
    try {
      print('DEBUG: Fetching popular listings (limit: $limit)');
      final listings = await getApprovedListings();

      // Sort by view count descending
      listings.sort((a, b) => b.itemViewCount.compareTo(a.itemViewCount));

      final popularListings = listings.take(limit).toList();
      print('DEBUG: Fetched ${popularListings.length} popular listings');
      return popularListings;
    } catch (e) {
      throw Exception('Failed to fetch popular listings: $e');
    }
  }

  // ==================== FETCH HIGH-RATED SELLER LISTINGS ====================

  /// Fetch listings from highly-rated sellers
  Future<List<ListingModel>> getHighRatedSellerListings(
    double minRating,
  ) async {
    try {
      print('DEBUG: Fetching listings from sellers with rating >= $minRating');
      final listings = await getApprovedListings();

      final filteredListings = listings
          .where((listing) => listing.sellerRating >= minRating)
          .toList();

      print(
        'DEBUG: Fetched ${filteredListings.length} listings from high-rated sellers',
      );
      return filteredListings;
    } catch (e) {
      throw Exception('Failed to fetch high-rated seller listings: $e');
    }
  }

  // ==================== STREAM LISTINGS ====================

  /// Stream all listings in real-time
  Stream<List<ListingModel>> streamAllListings() {
    return _itemsCollection.snapshots().asyncMap((itemSnapshot) async {
      List<ListingModel> listings = [];

      for (final itemDoc in itemSnapshot.docs) {
        try {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final item = Items.fromJson(itemData);

          // Fetch seller information
          final sellerDoc = await _usersCollection
              .where('userID', isEqualTo: item.sellerID)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData =
                sellerDoc.docs.first.data() as Map<String, dynamic>;
            final seller = Users.fromJson(sellerData);

            listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          print('DEBUG: Error in stream for item ${itemDoc.id}: $e');
          continue;
        }
      }

      return listings;
    });
  }

  /// Stream approved listings in real-time
  Stream<List<ListingModel>> streamApprovedListings() {
    return _itemsCollection
        .where('moderationStatus', isEqualTo: 'approved')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .asyncMap((itemSnapshot) async {
          List<ListingModel> listings = [];

          for (final itemDoc in itemSnapshot.docs) {
            try {
              final itemData = itemDoc.data() as Map<String, dynamic>;
              final item = Items.fromJson(itemData);

              // Fetch seller information
              final sellerDoc = await _usersCollection
                  .where('userID', isEqualTo: item.sellerID)
                  .limit(1)
                  .get();

              if (sellerDoc.docs.isNotEmpty) {
                final sellerData =
                    sellerDoc.docs.first.data() as Map<String, dynamic>;
                final seller = Users.fromJson(sellerData);

                listings.add(
                  ListingModel(
                    item: item,
                    seller: seller,
                    sellerID: item.sellerID,
                  ),
                );
              }
            } catch (e) {
              print(
                'DEBUG: Error in approved stream for item ${itemDoc.id}: $e',
              );
              continue;
            }
          }

          return listings;
        });
  }

  // ==================== SINGLE LISTING FETCH ====================

  /// Fetch a single listing by item ID
  Future<ListingModel?> getListingById(String itemId) async {
    try {
      print('DEBUG: Fetching listing for item $itemId');
      final itemDoc = await _itemsCollection.doc(itemId).get();

      if (!itemDoc.exists) {
        print('DEBUG: Item not found: $itemId');
        return null;
      }

      final itemData = itemDoc.data() as Map<String, dynamic>;
      final item = Items.fromJson(itemData);

      // Fetch seller information
      final sellerDoc = await _usersCollection
          .where('userID', isEqualTo: item.sellerID)
          .limit(1)
          .get();

      if (sellerDoc.docs.isEmpty) {
        print('DEBUG: Seller not found for item $itemId');
        return null;
      }

      final sellerData = sellerDoc.docs.first.data() as Map<String, dynamic>;
      final seller = Users.fromJson(sellerData);

      final listing = ListingModel(
        item: item,
        seller: seller,
        sellerID: item.sellerID,
      );

      print('DEBUG: Fetched listing for item $itemId');
      return listing;
    } catch (e) {
      throw Exception('Failed to fetch listing: $e');
    }
  }

  // ==================== CREATE LISTING ====================

  /// Create a new listing (item + seller relationship)
  Future<String?> createListing(Items item) async {
    try {
      print('DEBUG: Creating listing for item: ${item.title}');

      // Validate item data
      if (item.title.isEmpty || item.price < 0) {
        throw Exception('Invalid item data');
      }

      // Create the item in Firestore
      final itemId = await _itemService.createItem(item);

      if (itemId.isEmpty) {
        throw Exception('Failed to create item: No ID returned');
      }

      print('DEBUG: Listing created successfully with ID: $itemId');
      return itemId;
    } catch (e) {
      throw Exception('Failed to create listing: $e');
    }
  }

  /// Create multiple listings at once
  Future<List<String>> createMultipleListings(List<Items> items) async {
    try {
      print('DEBUG: Creating ${items.length} listings');
      List<String> itemIds = [];

      for (final item in items) {
        try {
          final itemId = await createListing(item);
          if (itemId != null) {
            itemIds.add(itemId);
          }
        } catch (e) {
          print('DEBUG: Error creating listing for ${item.title}: $e');
          continue;
        }
      }

      print('DEBUG: Successfully created ${itemIds.length} listings');
      return itemIds;
    } catch (e) {
      throw Exception('Failed to create multiple listings: $e');
    }
  }

  // ==================== UPDATE LISTING ====================

  /// Update listing details
  Future<bool> updateListing(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('DEBUG: Updating listing $itemId');

      // Validate updates
      if (updates.isEmpty) {
        throw Exception('No updates provided');
      }

      await _itemsCollection.doc(itemId).update(updates);

      print('DEBUG: Listing $itemId updated successfully');
      return true;
    } catch (e) {
      throw Exception('Failed to update listing: $e');
    }
  }

  /// Update listing price
  Future<bool> updateListingPrice(String itemId, double newPrice) async {
    try {
      print('DEBUG: Updating price for listing $itemId to ₱$newPrice');

      if (newPrice < 0) {
        throw Exception('Price cannot be negative');
      }

      await _itemsCollection.doc(itemId).update({'price': newPrice});

      print('DEBUG: Price updated successfully');
      return true;
    } catch (e) {
      throw Exception('Failed to update listing price: $e');
    }
  }

  /// Update listing quantity
  Future<bool> updateListingQuantity(String itemId, int newQuantity) async {
    try {
      print('DEBUG: Updating quantity for listing $itemId to $newQuantity');

      if (newQuantity < 0) {
        throw Exception('Quantity cannot be negative');
      }

      // Update quantity and status
      final newStatus = newQuantity > 0 ? 'available' : 'sold out';
      await _itemsCollection.doc(itemId).update({
        'quantity': newQuantity,
        'status': newStatus,
      });

      print('DEBUG: Quantity updated to $newQuantity, status: $newStatus');
      return true;
    } catch (e) {
      throw Exception('Failed to update listing quantity: $e');
    }
  }

  /// Update listing status
  Future<bool> updateListingStatus(String itemId, String newStatus) async {
    try {
      print('DEBUG: Updating status for listing $itemId to $newStatus');

      final validStatuses = ['available', 'sold out', 'removed'];
      if (!validStatuses.contains(newStatus)) {
        throw Exception('Invalid status: $newStatus');
      }

      await _itemsCollection.doc(itemId).update({'status': newStatus});

      print('DEBUG: Status updated to $newStatus');
      return true;
    } catch (e) {
      throw Exception('Failed to update listing status: $e');
    }
  }

  /// Update listing moderation status
  Future<bool> updateListingModerationStatus(
    String itemId,
    String status, {
    int? moderatorId,
    String? rejectionReason,
  }) async {
    try {
      print('DEBUG: Updating moderation status for listing $itemId to $status');

      final validStatuses = ['pending', 'approved', 'rejected', 'flagged'];
      if (!validStatuses.contains(status)) {
        throw Exception('Invalid moderation status: $status');
      }

      final updates = {
        'moderationStatus': status,
        'moderatedDate': FieldValue.serverTimestamp(),
        if (moderatorId != null) 'moderatedBy': moderatorId,
        if (rejectionReason != null) 'rejectionReason': rejectionReason,
      };

      await _itemsCollection.doc(itemId).update(updates);

      print('DEBUG: Moderation status updated to $status');
      return true;
    } catch (e) {
      throw Exception('Failed to update moderation status: $e');
    }
  }

  /// Update listing description and title
  Future<bool> updateListingDetails(
    String itemId,
    String title,
    String description,
  ) async {
    try {
      print('DEBUG: Updating details for listing $itemId');

      if (title.isEmpty || description.isEmpty) {
        throw Exception('Title and description cannot be empty');
      }

      await _itemsCollection.doc(itemId).update({
        'title': title,
        'description': description,
      });

      print('DEBUG: Listing details updated');
      return true;
    } catch (e) {
      throw Exception('Failed to update listing details: $e');
    }
  }

  // ==================== DELETE LISTING ====================

  /// Soft delete a listing (mark as removed, don't delete from database)
  Future<bool> softDeleteListing(String itemId) async {
    try {
      print('DEBUG: Soft deleting listing $itemId');

      await _itemsCollection.doc(itemId).update({
        'status': 'removed',
        'moderationStatus': 'flagged',
      });

      print('DEBUG: Listing $itemId marked as removed');
      return true;
    } catch (e) {
      throw Exception('Failed to soft delete listing: $e');
    }
  }

  /// Hard delete a listing (permanently remove from database)
  Future<bool> hardDeleteListing(String itemId) async {
    try {
      print('DEBUG: Hard deleting listing $itemId');

      await _itemsCollection.doc(itemId).delete();

      print('DEBUG: Listing $itemId permanently deleted');
      return true;
    } catch (e) {
      throw Exception('Failed to hard delete listing: $e');
    }
  }

  /// Delete multiple listings
  Future<List<String>> deleteMultipleListings(
    List<String> itemIds, {
    bool softDelete = true,
  }) async {
    try {
      print(
        'DEBUG: ${softDelete ? "Soft" : "Hard"} deleting ${itemIds.length} listings',
      );

      List<String> deletedIds = [];

      for (final itemId in itemIds) {
        try {
          final success = softDelete
              ? await softDeleteListing(itemId)
              : await hardDeleteListing(itemId);

          if (success) {
            deletedIds.add(itemId);
          }
        } catch (e) {
          print('DEBUG: Error deleting listing $itemId: $e');
          continue;
        }
      }

      print('DEBUG: Successfully deleted ${deletedIds.length} listings');
      return deletedIds;
    } catch (e) {
      throw Exception('Failed to delete multiple listings: $e');
    }
  }

  // ==================== FILTER & SORT HELPERS ====================

  /// Get seller performance metrics
  Future<Map<String, dynamic>> getSellerMetrics(int sellerID) async {
    try {
      print('DEBUG: Fetching metrics for seller $sellerID');

      final userDoc = await _usersCollection
          .where('userID', isEqualTo: sellerID)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        throw Exception('Seller not found');
      }

      final userData = userDoc.docs.first.data() as Map<String, dynamic>;
      final user = Users.fromJson(userData);

      final itemSnapshot = await _itemsCollection
          .where('sellerID', isEqualTo: sellerID)
          .get();

      int approvedCount = 0;
      int pendingCount = 0;
      int rejectedCount = 0;
      int totalViews = 0;
      int totalFavorites = 0;

      for (final itemDoc in itemSnapshot.docs) {
        final itemData = itemDoc.data() as Map<String, dynamic>;
        final item = Items.fromJson(itemData);

        switch (item.moderationStatus.toString()) {
          case 'ModerationStatus.approved':
            approvedCount++;
            break;
          case 'ModerationStatus.pending':
            pendingCount++;
            break;
          case 'ModerationStatus.rejected':
            rejectedCount++;
            break;
        }

        totalViews += item.viewCount;
        totalFavorites += item.favoriteCount;
      }

      final metrics = {
        'sellerID': sellerID,
        'sellerName': user.name,
        'totalListings': user.totalListings,
        'totalSales': user.totalSales,
        'totalPurchases': user.totalPurchases,
        'reputationScore': user.reputationScore,
        'approvedItems': approvedCount,
        'pendingItems': pendingCount,
        'rejectedItems': rejectedCount,
        'totalViews': totalViews,
        'totalFavorites': totalFavorites,
      };

      print('DEBUG: Fetched metrics for seller $sellerID');
      return metrics;
    } catch (e) {
      throw Exception('Failed to fetch seller metrics: $e');
    }
  }
}
