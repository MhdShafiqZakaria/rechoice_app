import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/viewmodels/cart_view_model.dart';
import 'package:rechoice_app/models/viewmodels/wishlist_view_model.dart';

class WishlistCard extends StatelessWidget {
  final Items items;
  final VoidCallback onRemove;
  const WishlistCard({super.key, required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      //2 X 6 grid
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  //item image
                  child: _buildItemImage(items.imagePath),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Consumer<WishlistViewModel>(
                  builder: (context, wishlistViewModel, child) {
                    final isInWishList = wishlistViewModel.isItemInWishlist(
                      items.itemID,
                    );
                    return InkWell(
                      onTap: () {
                        if (isInWishList) {
                          wishlistViewModel.removeFromWishlist(items.itemID);
                        } else {
                          wishlistViewModel.addToWishlist(items);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              spreadRadius: 1,
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: Icon(
                          isInWishList ? Icons.favorite : Icons.favorite_border,

                          color: isInWishList ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          //Product Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                //item price
                Text(
                  'RM${items.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Buttons Add to Cart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final cartVM = Provider.of<CartViewModel>(
                        context,
                        listen: false,
                      );
                      cartVM.addToCart(items);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                //delete button
                const SizedBox(width: 8),
                InkWell(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),

      //add to cart button alongside delete button
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
        return Image.file(
          file,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        );
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
