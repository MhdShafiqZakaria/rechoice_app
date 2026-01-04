import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';
import 'package:rechoice_app/models/services/local_storage_service.dart';

class ItemService {
  final FirestoreService _firestoreService;
  final LocalStorageService _localStorageService;

  ItemService(this._firestoreService, this._localStorageService);

  CollectionReference get _itemsCollection =>
      _firestoreService.firestoreInstance.collection('items');

  // ==================== CREATE ====================

  Future<String> createItem(Items item) async {
    try {
      final counterRef = _firestoreService.firestoreInstance
          .collection('metadata')
          .doc('itemCounter');

      int nextItemID = 1;
      final counterDoc = await counterRef.get();
      if (counterDoc.exists) {
        final data = counterDoc.data();
        nextItemID = (data?['count'] ?? 0) + 1;
      }

      await counterRef.set({'count': nextItemID});

      //Create item with proper itemID
      final itemWithID = item.copyWith(itemID: nextItemID);
      final docRef = await _itemsCollection.add(itemWithID.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create item: $e');
    }
  }

  // ==================== READ ====================

  Future<Items?> getItemById(String itemId) async {
    try {
      final doc = await _itemsCollection.doc(itemId).get();
      if (!doc.exists) return null;
      return Items.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get item: $e');
    }
  }

  Future<List<Items>> getAllItems() async {
    try {
      final snapshot = await _itemsCollection.get();
      return snapshot.docs
          .map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get items: $e');
    }
  }

  Future<List<Items>> getApprovedItems() async {
    try {
      final snapshot = await _itemsCollection
          .where('moderationStatus', isEqualTo: 'approved')
          .where('status', isEqualTo: 'available')
          .get();
      return snapshot.docs
          .map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get approved items: $e');
    }
  }

  Future<List<Items>> getItemsBySeller(int sellerId) async {
    print('DEBUG: Starting getItemsBySeller for sellerId: $sellerId');
    try {
      print('DEBUG: Querying Firestore for sellerID: $sellerId');
      final snapshot = await _itemsCollection
          .where('sellerID', isEqualTo: sellerId)
          .get();
      print('DEBUG: Snapshot received, docs count: ${snapshot.docs.length}');
      final items = snapshot.docs.map((doc) {
        print('DEBUG: Mapping doc ID: ${doc.id}');
        return Items.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      print('DEBUG: Mapped ${items.length} items, about to return');
      return items;
    } catch (e) {
      print('DEBUG: Error in getItemsBySeller: $e');
      throw Exception('Failed to get seller items: $e');
    }
  }

  Future<List<Items>> getItemsByCategory(int categoryId) async {
    try {
      final snapshot = await _itemsCollection
          .where('category.categoryID', isEqualTo: categoryId)
          .where('moderationStatus', isEqualTo: 'approved')
          .get();
      return snapshot.docs
          .map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get category items: $e');
    }
  }

  Future<List<Items>> getPendingItems() async {
    try {
      final snapshot = await _itemsCollection
          .where('moderationStatus', isEqualTo: 'pending')
          .orderBy('postedDate', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending items: $e');
    }
  }

  Stream<List<Items>> streamApprovedItems() {
    return _itemsCollection
        .where('moderationStatus', isEqualTo: 'approved')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  // ==================== UPDATE ====================

  Future<void> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _itemsCollection.doc(itemId).update(updates);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  Future<void> updateModerationStatus({
    required String itemId,
    required ModerationStatus status,
    required int moderatedBy,
    String? rejectionReason,
  }) async {
    try {
      final updates = {
        'moderationStatus': status.toString().split('.').last,
        'moderatedDate': DateTime.now().toIso8601String(),
        'moderatedBy': moderatedBy,
      };

      if (status == ModerationStatus.rejected && rejectionReason != null) {
        updates['rejectionReason'] = rejectionReason;
      }

      await _itemsCollection.doc(itemId).update(updates);
    } catch (e) {
      throw Exception('Failed to update moderation status: $e');
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      await _itemsCollection.doc(itemId).update({
        'quantity': newQuantity,
        'status': newQuantity > 0 ? 'available' : 'sold out',
      });
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  Future<void> incrementViewCount(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  Future<void> incrementFavoriteCount(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).update({
        'favoriteCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment favorite count: $e');
    }
  }

  Future<void> decrementFavoriteCount(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).update({
        'favoriteCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to decrement favorite count: $e');
    }
  }

  // ==================== DELETE ====================

  Future<void> deleteItem(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  Future<void> softDeleteItem(String itemId) async {
    try {
      await _itemsCollection.doc(itemId).update({'status': 'removed'});
    } catch (e) {
      throw Exception('Failed to soft delete item: $e');
    }
  }

  // ==================== SEARCH & FILTER ====================

  Future<List<Items>> searchItems(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final snapshot = await _itemsCollection
          .where('moderationStatus', isEqualTo: 'approved')
          .get();

      return snapshot.docs
          .map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>))
          .where(
            (item) =>
                item.title.toLowerCase().contains(lowerQuery) ||
                item.brand.toLowerCase().contains(lowerQuery) ||
                item.description.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search items: $e');
    }
  }

  Future<List<Items>> filterItems({
    int? categoryId,
    String? condition,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      Query query = _itemsCollection
          .where('moderationStatus', isEqualTo: 'approved')
          .where('status', isEqualTo: 'available');

      if (categoryId != null) {
        query = query.where('category.categoryID', isEqualTo: categoryId);
      }

      if (condition != null) {
        query = query.where('condition', isEqualTo: condition);
      }

      final snapshot = await query.get();
      var items = snapshot.docs
          .map((doc) => Items.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      if (minPrice != null) {
        items = items.where((item) => item.price >= minPrice).toList();
      }

      if (maxPrice != null) {
        items = items.where((item) => item.price <= maxPrice).toList();
      }

      return items;
    } catch (e) {
      throw Exception('Failed to filter items: $e');
    }
  }

  // Saves image locally and returns the local file path
  Future<String> uploadItemImage(File imageFile, String itemId) async {
    try {
      return await _localStorageService.saveItemImage(imageFile, itemId);
    } catch (e) {
      throw Exception('Failed to save image locally: $e');
    }
  }

  // Saves multiple images locally and returns a list of local file paths
  Future<List<String>> uploadMultipleImages(
    List<File> imageFiles,
    String itemId,
  ) async {
    try {
      return await _localStorageService.saveMultipleImages(imageFiles, itemId);
    } catch (e) {
      throw Exception('Failed to save images locally: $e');
    }
  }

  // Deletes local image by itemId (assumes LocalStorageService uses itemId for keys)
  Future<void> deleteItemImage(String itemId) async {
    try {
      await _localStorageService.deleteItemImage(itemId);
    } catch (e) {
      throw Exception('Failed to delete local image: $e');
    }
  }

  // ==================== LOCAL IMAGE ACCESS ====================

  // Get the local image file for an item
  File? getLocalItemImageFile(String itemId) {
  final file = _localStorageService.getItemImageFile(itemId);
  if (file != null && file.existsSync()) {
    return file;
  }
  return null;
}

  // Check if a local image exists for an item
  bool hasLocalImage(String itemId) {
    return _localStorageService.hasImage(itemId);
  }
}
