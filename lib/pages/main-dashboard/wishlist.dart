import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/wishlist/wishlist_card.dart';
import 'package:rechoice_app/models/viewmodels/cart_view_model.dart';
import 'package:rechoice_app/models/viewmodels/wishlist_view_model.dart';

class WishlistPage extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const WishlistPage({super.key, this.onBackPressed});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WishlistViewModel>(
      builder: (context, wishlistVM, child) {
        final items = wishlistVM.items;
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body
          // : wishlistVM.items.isEmpty
          //     ? _buildEmptyWishlist()
          : Column(
            children: [
              // Header Section with Blue Background
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1976D2),
                      Color(0xFF2196F3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              if (widget.onBackPressed != null) {
                                widget.onBackPressed!();
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'My Wishlist',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Content Section
              Expanded(
                child: Column(
                  children: [
                    // Items Count and Clear All
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${items.length} Items',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: items.isEmpty
                                ? null
                                : wishlistVM.clearAllFromWishList,
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Wishlist Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return WishlistCard(
                            items: items[index],
                            onRemove: () => wishlistVM.removeFromWishlist(
                              items[index].itemID,
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Section
                    if (items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade50,
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Items:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  '${items.length} Items',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final cartVM = Provider.of<CartViewModel>(
                                    context,
                                    listen: false,
                                  );
                                  //add all item from wishlist to cart
                                  for (var item in items.toList()) {
                                    cartVM.addFromWishlist(item);
                                  }
                                  ;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Add All to Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildEmptyWishlist() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.favorite_border, size: 100, color: Colors.grey.shade400),
  //         const SizedBox(height: 16),
  //         Text(
  //           'Your wishlist is empty',
  //           style: TextStyle(
  //             fontSize: 18,
  //             color: Colors.grey.shade600,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         Text(
  //           'Add items you love to your wishlist',
  //           style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
  //         ),
  //         const SizedBox(height: 24),
  //         ElevatedButton(
  //           onPressed: () => Navigator.pop(context),
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: const Color(0xFF2E5C9A),
  //             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
  //           ),
  //           child: const Text(
  //             'Start Shopping',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
