import 'package:rechoice_app/models/model/items_model.dart';

class CartItem {
  final Items items;
  int quantity;

  CartItem({required this.items, this.quantity = 1});

  // Firebase ready - fromJson
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      items: Items.fromJson(json['item']),
      quantity: (json['quantity'] as int?) ?? 1,
    );
  }

  // Firebase ready - toJson
  Map<String, dynamic> toJson() {
    return {'item': items.toJson(), 'quantity': quantity};
  }

  // Helper function to calculate totalPrice of cart
  double get totalPrice => (items.price) * quantity;

  // Formatted subtotal
  String get formattedSubtotal => 'RM${totalPrice.toStringAsFixed(2)}';

  // Check if item is in stock
  bool get isInStock => items.quantity >= quantity;

  // Copy with method
  CartItem copyWith({Items? items, int? quantity, DateTime? addedAt}) {
    return CartItem(
      items: items ?? this.items,
      quantity: quantity ?? this.quantity,
    );
  }
}
