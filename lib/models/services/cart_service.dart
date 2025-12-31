import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/cart_model.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';

class CartService {
  final FirestoreService _firestoreService;
  
  CartService(this._firestoreService);

  CollectionReference _getCartCollection(String userId) => 
      _firestoreService.firestoreInstance
          .collection('users')
          .doc(userId)
          .collection('carts');

  // ==================== CREATE ====================
  
  Future<void> addToCart(String userId, CartItem cartItem) async {
    try {
      await _getCartCollection(userId)
          .doc(cartItem.items.itemID.toString())
          .set(cartItem.toJson());
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  // ==================== READ ====================
  
  Future<List<CartItem>> getCart(String userId) async {
    try {
      final snapshot = await _getCartCollection(userId).get();
      return snapshot.docs
          .map((doc) => CartItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cart: $e');
    }
  }

  Future<CartItem?> getCartItem(String userId, int itemId) async {
    try {
      final doc = await _getCartCollection(userId)
          .doc(itemId.toString())
          .get();
      
      if (!doc.exists) return null;
      return CartItem.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get cart item: $e');
    }
  }

  Stream<List<CartItem>> streamCart(String userId) {
    return _getCartCollection(userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItem.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ==================== UPDATE ====================
  
  Future<void> updateQuantity(String userId, int itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await removeFromCart(userId, itemId);
        return;
      }
      
      await _getCartCollection(userId)
          .doc(itemId.toString())
          .update({'quantity': newQuantity});
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  Future<void> incrementQuantity(String userId, int itemId) async {
    try {
      await _getCartCollection(userId)
          .doc(itemId.toString())
          .update({
        'quantity': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to increment quantity: $e');
    }
  }

  Future<void> decrementQuantity(String userId, int itemId) async {
    try {
      final cartItem = await getCartItem(userId, itemId);
      if (cartItem == null) return;
      
      if (cartItem.quantity <= 1) {
        await removeFromCart(userId, itemId);
      } else {
        await _getCartCollection(userId)
            .doc(itemId.toString())
            .update({
          'quantity': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      throw Exception('Failed to decrement quantity: $e');
    }
  }

  // ==================== DELETE ====================
  
  Future<void> removeFromCart(String userId, int itemId) async {
    try {
      await _getCartCollection(userId)
          .doc(itemId.toString())
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      final batch = _firestoreService.firestoreInstance.batch();
      final snapshot = await _getCartCollection(userId).get();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ==================== BATCH OPERATIONS ====================
  
  Future<void> addMultipleToCart(String userId, List<CartItem> items) async {
    try {
      final batch = _firestoreService.firestoreInstance.batch();
      
      for (var item in items) {
        final docRef = _getCartCollection(userId)
            .doc(item.items.itemID.toString());
        batch.set(docRef, item.toJson());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to add multiple items: $e');
    }
  }

  Future<void> removeMultipleFromCart(String userId, List<int> itemIds) async {
    try {
      final batch = _firestoreService.firestoreInstance.batch();
      
      for (var itemId in itemIds) {
        final docRef = _getCartCollection(userId).doc(itemId.toString());
        batch.delete(docRef);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove multiple items: $e');
    }
  }

  // ==================== UTILITY ====================
  
  Future<int> getCartItemCount(String userId) async {
    try {
      final snapshot = await _getCartCollection(userId).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get cart count: $e');
    }
  }

  Future<int> getTotalQuantity(String userId) async {
    try {
      final cart = await getCart(userId);
      return cart.fold<int>(0, (sum, item) => sum + item.quantity);
    } catch (e) {
      throw Exception('Failed to get total quantity: $e');
    }
  }

  Future<double> getCartTotal(String userId) async {
    try {
      final cart = await getCart(userId);
      return cart.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
    } catch (e) {
      throw Exception('Failed to get cart total: $e');
    }
  }

  Future<bool> isItemInCart(String userId, int itemId) async {
    try {
      final doc = await _getCartCollection(userId)
          .doc(itemId.toString())
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ==================== VALIDATION ====================
  
  Future<List<CartItem>> validateCartStock(String userId) async {
    try {
      final cart = await getCart(userId);
      final outOfStock = <CartItem>[];
      
      for (var cartItem in cart) {
        if (!cartItem.isInStock) {
          outOfStock.add(cartItem);
        }
      }
      
      return outOfStock;
    } catch (e) {
      throw Exception('Failed to validate cart: $e');
    }
  }
}