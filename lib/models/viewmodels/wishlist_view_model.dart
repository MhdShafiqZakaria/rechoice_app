import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rechoice_app/models/model/items_model.dart';

class WishlistViewModel extends ChangeNotifier {
  //initialize Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //List for holding the  list of wishlist items
  final List<Items> _wishlistItems = [];

  //Loading and error states for UI feedback
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  //Getter function for item count
  int get itemCount => _wishlistItems.length;

  //Getter function for current list (read-only)
  List<Items> get items => List.unmodifiable(_wishlistItems);

  // Get current user ID
  String? get _userID => FirebaseAuth.instance.currentUser?.uid;

  // ====================  CRUD OPERATIONS ====================

  Future<void> loadWishlist() async {
    //validate user
    if (_userID == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch wishlist data from Firestore
      final snapshot = await _db
          .collection('users')
          .doc(_userID)
          .collection('wishlists')
          .get();
      _wishlistItems.clear();
      for (var doc in snapshot.docs) {
        _wishlistItems.add(Items.fromJson(doc.data()));
      }
    } catch (e) {
      _errorMessage = 'Failed to load wishlist: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Method to add the items to the wishlist
  Future <void> addToWishlist(Items items) async {
    // Validate user
    if (_userID == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }
    //check if the items is already in the list
    if (_wishlistItems.any((product) => product.itemID == items.itemID)) {
      _errorMessage = 'Item already in wishlist';
      notifyListeners();
      return;
    }

    try {
      // Create a new list with the added item and update the state
      _wishlistItems.add(items);
      notifyListeners();

      await _db
          .collection('users')
          .doc(_userID)
          .collection('wishlists')
          .doc(items.itemID.toString())
          .set(items.toJson());
    } catch (e) {
      _wishlistItems.removeWhere((product) => product.itemID == items.itemID);
      _errorMessage = 'Failed to remove item: $e';
      notifyListeners();
    }
  }

  //Method to remove the items from the wishlist
  Future <void> removeFromWishlist(int itemsID) async {
    // Validate user
    if (_userID == null) return;
    final removedItem = _wishlistItems.firstWhere(
      (product) => product.itemID == itemsID,
      orElse: () => throw StateError('Item not found in wishlist'),
    );

    try {
      // Filter the list to remove the specified item and update the list
      _wishlistItems.removeWhere((product) => product.itemID == itemsID);
      notifyListeners();

      await _db
          .collection('users')
          .doc(_userID)
          .collection('wishlists')
          .doc(itemsID.toString())
          .delete();
    } catch (e) {
      _wishlistItems.add(removedItem);
      _errorMessage = 'Failed to remove item: $e';
      notifyListeners();
    }
  }

  //Method to clear all items in the wishkist
  Future <void> clearAllFromWishList() async {
    // Validate user
    if (_userID == null) return;
    final backup = List<Items>.from(_wishlistItems);
    try {
      _wishlistItems.clear();
      notifyListeners();

      final batch = _db.batch();
      final snapshot = await _db
          .collection('users')
          .doc(_userID)
          .collection('wishlists')
          .get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _wishlistItems.addAll(backup);
      _errorMessage = 'Failed to clear wishlist: $e';
      notifyListeners();
    }
  }

  // Method to check if a item is in the wishlist
  bool isItemInWishlist(int itemsID) {
    return _wishlistItems.any((product) => product.itemID == itemsID);
  }
}
