import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rechoice_app/models/model/cart_model.dart';

// Payment Summary Card Widget
class PaymentCard extends StatelessWidget {
  final CartItem cartItems;
  const PaymentCard({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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

      child: Column(
        children: [
          // Product Info
          Row(
            children: [
              //Check it is a local file path
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildItemImage(cartItems.items.imagePath)
              ),
              const SizedBox(width: 16),
              Column(
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
                    'RM${cartItems.items.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItemImage(String imagePath) {
  if (imagePath.isEmpty) {
    return Center(
      child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
    );
  }
  
  // Local file path
  if (imagePath.startsWith('/')) {
    final file = File(imagePath);
    if (file.existsSync()) {
      return Image.file(file, width: double.infinity, height: 180, fit: BoxFit.cover);
    }
  }
  
  // Network URL
  if (imagePath.startsWith('http')) {
    return Image.network(
      imagePath,
      width: double.infinity,
      height: 180,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
      ),
    );
  }
  
  // Fallback
  return Center(
    child: Icon(Icons.image_outlined, size: 60, color: Colors.grey),
  );
}
}
