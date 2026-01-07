import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/services/listing_notification_service.dart';

class ListingModerationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ListingNotificationService _notificationService =
      ListingNotificationService();

  /// Fetch all listings or filter by status
  Future<List<Map<String, dynamic>>> getListings({String? statusFilter}) async {
    try {
      Query query = _firestore.collection('items');

      // Only filter by status if provided
      if (statusFilter != null && statusFilter.isNotEmpty) {
        query = query.where('moderationStatus', isEqualTo: statusFilter);
      }

      // Removed orderBy to avoid Firestore index requirement
      // Sorting will be done in memory instead

      final snapshot = await query.get();
      var listings = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      // Sort by createdAt in memory (descending)
      listings.sort((a, b) {
        final aCreated = a['createdAt'];
        final bCreated = b['createdAt'];

        if (aCreated == null && bCreated == null) return 0;
        if (aCreated == null) return 1;
        if (bCreated == null) return -1;

        // Handle both Timestamp and DateTime
        final aTime = aCreated is Timestamp
            ? aCreated.toDate()
            : (aCreated as DateTime?);
        final bTime = bCreated is Timestamp
            ? bCreated.toDate()
            : (bCreated as DateTime?);

        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // descending
      });

      // If no listings found and no status filter, add test data
      if (listings.isEmpty && statusFilter == null) {
        print('⚠️ No listings in Firestore, adding test data');
        listings = _getMockTestData();
      }

      print('✅ Loaded ${listings.length} listings from Firestore');
      return listings;
    } catch (e) {
      print('❌ Error fetching listings: $e');
      // Return mock data as fallback
      print('⚠️ Using fallback mock data');
      return _getMockTestData();
    }
  }

  /// Get mock test data for demonstration
  List<Map<String, dynamic>> _getMockTestData() {
    return [
      {
        'id': 'MOCK001',
        'title': 'iPhone 14 Pro',
        'category': 'Electronics',
        'price': 999.99,
        'status': 'pending',
        'sellerName': 'John Doe',
        'createdAt': Timestamp.now(),
        'views': 245,
        'description': 'Excellent condition iPhone 14 Pro, minimal scratches',
      },
      {
        'id': 'MOCK002',
        'title': 'Winter Jacket',
        'category': 'Fashion',
        'price': 89.99,
        'status': 'pending',
        'sellerName': 'Jane Smith',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        'views': 120,
        'description': 'New winter jacket, size M, never worn',
      },
      {
        'id': 'MOCK003',
        'title': 'Coffee Table',
        'category': 'Home & Living',
        'price': 149.99,
        'status': 'pending',
        'sellerName': 'Mike Johnson',
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 5)),
        ),
        'views': 45,
        'description': 'Wooden coffee table in good condition, solid oak',
      },
    ];
  }

  /// Search listings by title, description, or seller name
  Future<List<Map<String, dynamic>>> searchListings(
    String query, {
    String? statusFilter,
  }) async {
    try {
      // Firestore doesn't support full-text search directly,
      // so we fetch all listings and filter in memory
      var listings = await getListings(statusFilter: statusFilter);

      if (query.isEmpty) {
        return listings;
      }

      final queryLower = query.toLowerCase();
      final filtered = listings.where((listing) {
        final title = (listing['title'] ?? '').toString().toLowerCase();
        final description = (listing['description'] ?? '')
            .toString()
            .toLowerCase();
        final sellerName = (listing['sellerName'] ?? '')
            .toString()
            .toLowerCase();

        return title.contains(queryLower) ||
            description.contains(queryLower) ||
            sellerName.contains(queryLower);
      }).toList();

      print('✅ Search found ${filtered.length} results for "$query"');
      return filtered;
    } catch (e) {
      print('❌ Error searching listings: $e');
      rethrow;
    }
  }

  /// Approve a listing by updating its status
  Future<void> approveListingAsync(String itemId) async {
    try {
      // Get listing details before updating
      final doc = await _firestore.collection('items').doc(itemId).get();
      final listingData = doc.data();

      // Update listing status
      await _firestore.collection('items').doc(itemId).update({
        'moderationStatus': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
        'moderatedBy': 'admin_user',
        'moderatedDate': FieldValue.serverTimestamp(),
      });

      // Send notification to seller
      if (listingData != null) {
        final sellerUserId = listingData['sellerId'] ?? listingData['userId'];
        final listingTitle = listingData['title'] ?? 'Your listing';

        if (sellerUserId != null) {
          await _notificationService.notifyListingStatusChange(
            listingId: itemId,
            sellerUserId: sellerUserId,
            listingTitle: listingTitle,
            status: ModerationStatus.approved,
          );
        }
      }

      print('✅ Listing $itemId approved and notification sent');
    } catch (e) {
      print('❌ Error approving listing: $e');
      rethrow;
    }
  }

  /// Reject a listing by updating its status
  Future<void> rejectListingAsync(String itemId, {String? reason}) async {
    try {
      // Get listing details before updating
      final doc = await _firestore.collection('items').doc(itemId).get();
      final listingData = doc.data();

      // Update listing status
      await _firestore.collection('items').doc(itemId).update({
        'status': 'rejected',
        'moderationStatus': 'rejected',
        'moderatedBy': 'admin_user',
        'updatedAt': FieldValue.serverTimestamp(),
        'rejectionReason': reason ?? 'Does not meet our guidelines',
        'moderatedDate': FieldValue.serverTimestamp(),
      });

      // Send notification to seller
      if (listingData != null) {
        final sellerUserId = listingData['sellerId'] ?? listingData['userId'];
        final listingTitle = listingData['title'] ?? 'Your listing';

        if (sellerUserId != null) {
          await _notificationService.notifyListingStatusChange(
            listingId: itemId,
            sellerUserId: sellerUserId,
            listingTitle: listingTitle,
            status: ModerationStatus.rejected,
            rejectionReason: reason,
          );
        }
      }

      print('✅ Listing $itemId rejected and notification sent');
    } catch (e) {
      print('❌ Error rejecting listing: $e');
      rethrow;
    }
  }

  /// Flag a listing as inappropriate/problematic
  Future<void> flagListingAsync(String itemId, {String? reason}) async {
    try {
      // Get listing details before updating
      final doc = await _firestore.collection('items').doc(itemId).get();
      final listingData = doc.data();

      // Update listing status
      await _firestore.collection('items').doc(itemId).update({
        'status': 'flagged',
        'moderationStatus': 'flagged',
        'updatedAt': FieldValue.serverTimestamp(),
        'flagReason': reason ?? 'Flagged by admin',
      });

      // Send notification to seller
      if (listingData != null) {
        final sellerUserId = listingData['sellerId'] ?? listingData['userId'];
        final listingTitle = listingData['title'] ?? 'Your listing';

        if (sellerUserId != null) {
          await _notificationService.notifyListingStatusChange(
            listingId: itemId,
            sellerUserId: sellerUserId,
            listingTitle: listingTitle,
            status: ModerationStatus.flagged,
            rejectionReason: reason,
          );
        }
      }

      print('✅ Listing $itemId flagged and notification sent');
    } catch (e) {
      print('❌ Error flagging listing: $e');
      rethrow;
    }
  }

  /// Get count of listings by status
  Future<int> getListingCountByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection('items')
          .where('status', isEqualTo: status)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting listing count: $e');
      return 0;
    }
  }
}
