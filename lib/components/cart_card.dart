import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/quantity_selector.dart';
import 'package:rechoice_app/models/model/cart_model.dart';
import 'package:rechoice_app/models/viewmodels/cart_view_model.dart';

// Cart Item Widget
class CartCard extends StatelessWidget {
  final CartItem cartItems;

  const CartCard({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    final CartViewModel cartViewModel = Provider.of<CartViewModel>(
      context,
      listen: false,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              cartItems.items.imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItems.items.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cartItems.items.brand,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'RM${cartItems.items.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          // Remove Button & Quantity Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => cartViewModel.removeFromCart(cartItems.items),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 12),
              QuantitySelector(cartItem: cartItems),
            ],
          ),
        ],
      ),
    );
  }
}
