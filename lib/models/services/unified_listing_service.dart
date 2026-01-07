import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/model/listing_model.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/services/listing_service.dart';
import 'package:rechoice_app/models/services/listing_moderation_service.dart';

/// Unified facade for all listing operations
/// Delegates to appropriate underlying services
class UnifiedListingService {
  final ListingService _listingService;
  final ListingModerationService _moderationService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UnifiedListingService(this._listingService, this._moderationService);

  // ==================== LISTING SERVICE DELEGATES ====================

  Future<List<ListingModel>> getAllListings() =>
      _listingService.getAllListings();

  Future<List<ListingModel>> getApprovedListings() =>
      _listingService.getApprovedListings();

  Future<List<ListingModel>> getSellerListings(int sellerID) =>
      _listingService.getSellerListings(sellerID);

  Future<List<ListingModel>> getListingsByCategory(int categoryId) =>
      _listingService.getListingsByCategory(categoryId);

  Future<List<ListingModel>> searchListings(String query) =>
      _listingService.searchListings(query);

  Future<List<ListingModel>> getListingsByPriceRange(
    double minPrice,
    double maxPrice,
  ) => _listingService.getListingsByPriceRange(minPrice, maxPrice);

  Future<List<ListingModel>> getListingsByCondition(String condition) =>
      _listingService.getListingsByCondition(condition);

  Future<List<ListingModel>> getPopularListings({int limit = 10}) =>
      _listingService.getPopularListings(limit: limit);

  Future<List<ListingModel>> getHighRatedSellerListings(double minRating) =>
      _listingService.getHighRatedSellerListings(minRating);

  Stream<List<ListingModel>> streamAllListings() =>
      _listingService.streamAllListings();

  Stream<List<ListingModel>> streamApprovedListings() =>
      _listingService.streamApprovedListings();

  Future<ListingModel?> getListingById(String itemId) =>
      _listingService.getListingById(itemId);

  Future<String?> createListing(Items item) =>
      _listingService.createListing(item);

  Future<List<String>> createMultipleListings(List<Items> items) =>
      _listingService.createMultipleListings(items);

  Future<bool> updateListing(String itemId, Map<String, dynamic> updates) =>
      _listingService.updateListing(itemId, updates);

  Future<bool> updateListingPrice(String itemId, double newPrice) =>
      _listingService.updateListingPrice(itemId, newPrice);

  Future<bool> updateListingQuantity(String itemId, int newQuantity) =>
      _listingService.updateListingQuantity(itemId, newQuantity);

  Future<bool> updateListingStatus(String itemId, String newStatus) =>
      _listingService.updateListingStatus(itemId, newStatus);

  Future<bool> updateListingModerationStatus(
    String itemId,
    String status, {
    int? moderatorId,
    String? rejectionReason,
  }) => _listingService.updateListingModerationStatus(
    itemId,
    status,
    moderatorId: moderatorId,
    rejectionReason: rejectionReason,
  );

  Future<bool> updateListingDetails(
    String itemId,
    String title,
    String description,
  ) => _listingService.updateListingDetails(itemId, title, description);

  Future<bool> softDeleteListing(String itemId) =>
      _listingService.softDeleteListing(itemId);

  Future<bool> hardDeleteListing(String itemId) =>
      _listingService.hardDeleteListing(itemId);

  Future<List<String>> deleteMultipleListings(
    List<String> itemIds, {
    bool softDelete = true,
  }) => _listingService.deleteMultipleListings(itemIds, softDelete: softDelete);

  Future<Map<String, dynamic>> getSellerMetrics(int sellerID) =>
      _listingService.getSellerMetrics(sellerID);

  // ==================== MODERATION SERVICE DELEGATES ====================

  /// Fetch moderation listings with seller information enriched
  Future<List<Map<String, dynamic>>> getModerationListings({
    String? statusFilter,
  }) async {
    try {
      final listings = await _moderationService.getListings(
        statusFilter: statusFilter,
      );
      return await _enrichListingsWithSellerInfo(listings);
    } catch (e) {
      print('❌ Error in getModerationListings: $e');
      rethrow;
    }
  }

  /// Search moderation listings with seller information enriched
  Future<List<Map<String, dynamic>>> searchModerationListings(
    String query, {
    String? statusFilter,
  }) async {
    try {
      final listings = await _moderationService.searchListings(
        query,
        statusFilter: statusFilter,
      );
      return await _enrichListingsWithSellerInfo(listings);
    } catch (e) {
      print('❌ Error in searchModerationListings: $e');
      rethrow;
    }
  }

  /// Enrich listings with seller information from users collection
  Future<List<Map<String, dynamic>>> _enrichListingsWithSellerInfo(
    List<Map<String, dynamic>> listings,
  ) async {
    final enrichedListings = <Map<String, dynamic>>[];

    for (final listing in listings) {
      try {
        final enrichedListing = Map<String, dynamic>.from(listing);

        // Get seller ID from listing (try different field names)
        final sellerId =
            listing['sellerID'] ?? listing['sellerId'] ?? listing['userId'];

        if (sellerId != null) {
          // Fetch seller info from users collection
          final sellerDoc = await _firestore
              .collection('users')
              .where('userID', isEqualTo: sellerId)
              .limit(1)
              .get();

          if (sellerDoc.docs.isNotEmpty) {
            final sellerData = sellerDoc.docs.first.data();
            final seller = Users.fromJson(sellerData);

            // Add seller information to listing
            enrichedListing['sellerName'] = seller.name;
            enrichedListing['sellerEmail'] = seller.email;
            enrichedListing['sellerPhone'] = seller.phoneNumber;
            enrichedListing['sellerRating'] = seller.reputationScore;
            enrichedListing['sellerTotalListings'] = seller.totalListings;
            enrichedListing['sellerJoinDate'] = seller.joinDate;
          } else {
            // Seller not found, use defaults
            enrichedListing['sellerName'] = 'Unknown Seller';
          }
        } else {
          enrichedListing['sellerName'] = 'Unknown Seller';
        }

        enrichedListings.add(enrichedListing);
      } catch (e) {
        print('⚠️ Error enriching listing ${listing['id']}: $e');
        // Add listing without seller info
        enrichedListings.add(listing);
      }
    }

    return enrichedListings;
  }

  Future<void> approveListing(String itemId) =>
      _moderationService.approveListingAsync(itemId);

  Future<void> rejectListing(String itemId, {String? reason}) =>
      _moderationService.rejectListingAsync(itemId, reason: reason);

  Future<void> flagListing(String itemId, {String? reason}) =>
      _moderationService.flagListingAsync(itemId, reason: reason);

  Future<int> getListingCountByStatus(String status) =>
      _moderationService.getListingCountByStatus(status);
}
