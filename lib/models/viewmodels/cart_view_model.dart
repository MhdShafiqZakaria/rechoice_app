import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/viewmodels/wishlist_view_model.dart';
import 'package:rechoice_app/models/model/cart_model.dart';

class CartViewModel extends ChangeNotifier {
  //initialize Firebase Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //add wishlist view model
  final WishlistViewModel wishlistViewModel;

  // List for holding the cart item
  final List<CartItem> _cartItems = [];

  CartViewModel({required this.wishlistViewModel});

  // ==================== GETTERS ====================

  // Get current user ID
  String? get _userID => FirebaseAuth.instance.currentUser?.uid;

  //Loading and error states for UI feedback
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  // for current list (read-only)
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  // unique types of items
  int get uniqueItemCount => _cartItems.length;

  // get quantity of specific item in cart
  int getItemQuantity(int itemId) {
    try {
      final cartItem = _cartItems.firstWhere(
        (item) => item.items.itemID == itemId,
      );
      return cartItem.quantity;
    } catch (e) {
      return 0;
    }
  }

  int get totalQuantity =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // grand total price of cart
  double get grandTotalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  // ==================== LOAD FROM FIREBASE ====================

  Future<void> loadCart() async {
    //validate user
    if (_userID == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Fetch cart data from Firestore
      final snapshot = await _db
          .collection('users')
          .doc(_userID)
          .collection('carts')
          .get();
      _cartItems.clear();
      for (var doc in snapshot.docs) {
        _cartItems.add(CartItem.fromJson(doc.data()));
      }
    } catch (e) {
      _errorMessage = 'Failed to load cart: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== CRUD OPERATIONS ====================

  //add to cart Method
  Future<void> addToCart(Items item) async {
    //validate user
    if (_userID == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }
    //check if the product is already in the cart
    int index = _cartItems.indexWhere(
      (cartItem) => cartItem.items.itemID == item.itemID,
    );

    // check stock availability
    int currentCartQuantity =
        index != -1 ? _cartItems[index].quantity : 0;
        if (currentCartQuantity + 1 > item.quantity) {
          _errorMessage = 'Cannot add more - only ${item.quantity} in stock';
          notifyListeners();
          return;
        }

    //backup previous state for rollback on error
    CartItem? previousState;
    int? previousIndex;

    try {
      if (index != -1) {
        previousState = CartItem(
          items: _cartItems[index].items,
          quantity: _cartItems[index].quantity,
        );
        previousIndex = index;
        // If it exists, increase the quantity of the existing CartItem
        _cartItems[index].quantity++;
      } else {
        // If it's new, add a new CartItem model instance
        _cartItems.add(CartItem(items: item));
      }
      notifyListeners();
      final cartItem = _cartItems.firstWhere(
        (cartItem) => cartItem.items.itemID == item.itemID,
      );

      await _db
          .collection('users')
          .doc(_userID)
          .collection('carts')
          .doc(item.itemID.toString())
          .set(cartItem.toJson());
    } catch (e) {
      // Revert to previous state on error
      if (previousState != null && previousIndex != null) {
        _cartItems[previousIndex] = previousState;
      } else {
        _cartItems.removeWhere(
          (cartItem) => cartItem.items.itemID == item.itemID,
        );
      }
      _errorMessage = 'Failed to add to cart: $e';
      notifyListeners();
    }
  }

  //Methods for moving all product from wishlist
  Future<void> addFromWishlist(Items item) async {
    //validate user
    if (_userID == null) return;
    try {
      // add wishlist item to cart
      await addToCart(item);
      //delete added item from wishlist
      await wishlistViewModel.removeFromWishlist(item.itemID);
    } catch (e) {
      _errorMessage = 'Failed to move item from wishlist to cart: $e';
      notifyListeners();
    }
  }

  // remove item from cart method
  Future<void> removeFromCart(Items item) async {
    //validate user
    if (_userID == null) return;
    final removedItem = _cartItems.firstWhere(
      (cartItem) => cartItem.items.itemID == item.itemID,
      orElse: () => throw StateError('Item not found in cart'),
    );
    try {
      _cartItems.removeWhere(
        (cartItem) => cartItem.items.itemID == item.itemID,
      );
      notifyListeners();

      await _db
          .collection('users')
          .doc(_userID)
          .collection('carts')
          .doc(item.itemID.toString())
          .delete();
    } catch (e) {
      _cartItems.add(removedItem);
      _errorMessage = 'Failed to remove item: $e';
      notifyListeners();
    }
  }

  // decrease the quantity of item in cart
  Future<void> decreaseQuantity(Items item) async {
    //validate user
    if (_userID == null) return;

    int index = _cartItems.indexWhere(
      (cartItem) => cartItem.items.itemID == item.itemID,
    );

    if (index == -1) return; // Item not found in cart

    final previousQuatity = _cartItems[index].quantity;
    final willRemove = previousQuatity <= 1;
    CartItem? removedItem;
    try {
      if (willRemove) {
        removedItem = _cartItems[index];
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity--;
      }
      notifyListeners();
      if (willRemove) {
        await _db
            .collection('users')
            .doc(_userID)
            .collection('carts')
            .doc(item.itemID.toString())
            .delete();
      } else {
        await _db
            .collection('users')
            .doc(_userID)
            .collection('carts')
            .doc(item.itemID.toString())
            .update({'quantity': _cartItems[index].quantity});
      }
    } catch (e) {
      if (willRemove && removedItem != null) {
        _cartItems.add(removedItem);
      } else {
        _cartItems[index].quantity = previousQuatity;
      }
      _errorMessage = 'Failed to decrease quantity: $e';
      notifyListeners();
    }
  }

  //clear cart
  Future<void> clearCart() async {
    // Validate user
    if (_userID == null) return;
    final backup = List<CartItem>.from(_cartItems);
    try {
      _cartItems.clear();
      notifyListeners();

      final batch = _db.batch();
      final snapshot = await _db
          .collection('users')
          .doc(_userID)
          .collection('carts')
          .get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      _cartItems.addAll(backup);
      _errorMessage = 'Failed to clear cart: $e';
      notifyListeners();
    }
  }
}
