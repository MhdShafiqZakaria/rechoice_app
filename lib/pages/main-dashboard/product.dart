import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/services/dummy_data.dart';
import 'package:rechoice_app/models/viewmodels/cart_view_model.dart';
import 'package:rechoice_app/models/viewmodels/wishlist_view_model.dart';
import 'package:rechoice_app/utils/build_item_image.dart';

class Product extends StatefulWidget {
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  late Items currentItem;
  Color? selectedColor;
  final List<Color> colorOptions = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract argument here
    currentItem = ModalRoute.of(context)!.settings.arguments as Items;
  }

  @override
  void initState() {
    super.initState();
    currentItem = DummyData.getFeaturedProducts()[0];
  }

  @override
  Widget build(BuildContext context) {
    final CartViewModel cartVM = Provider.of<CartViewModel>(
      context,
      listen: false,
    );

    return Scaffold(
      //App Bar
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              iconSize: 20,
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                iconSize: 20,
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D47A1), // Colors.blue[900]
                Color(0xFF1976D2), // Colors.blue[700]
                Color(0xFF2196F3), // Colors.blue[500]
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      //Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Items image
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: buildItemImage(currentItem.imagePath, 80),
                ),
              ),
              const SizedBox(height: 16), // Spacing
              // Row nama product icon love
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentItem.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Consumer<WishlistViewModel>(
                    builder: (context, wishlistViewModel, child) {
                      final isInWishList = wishlistViewModel.isItemInWishlist(
                        currentItem.itemID,
                      );
                      // Wishlist button
                      return IconButton(
                        icon: Icon(
                          //check if the wishlist item is in the list yet
                          isInWishList ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          if (isInWishList) {
                            wishlistViewModel.removeFromWishlist(
                              currentItem.itemID,
                            );
                          } else {
                            wishlistViewModel.addToWishlist(currentItem);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 1),

              // Price
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RM ${currentItem.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              //Option
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Color',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              //Option buttons
              const SizedBox(height: 16),
              // Row dengan 3 container
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: colorOptions
                    .map(
                      (color) => _ColorOption(
                        color: color,
                        isSelected: selectedColor == color,
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              //Quantity
              Row(
                children: [
                  const Text(
                    'Quantity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        //Minus button
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => cartVM.decreaseQuantity(currentItem),
                        ),

                        Consumer<CartViewModel>(
                          builder: (context, cartVM, child) {
                            final quantity = cartVM.getItemQuantity(
                              currentItem.itemID,
                            );
                            return Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),

                        //Plus button
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cartVM.addToCart(currentItem),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              //Description
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentItem.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      //Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50,
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 2 ikon kiri
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  icon: const Icon(Icons.smart_toy),
                  iconSize: 28,
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context,'/inAppChat');
                  },
                  icon: const Icon(Icons.message),
                  iconSize: 28,
                  color: Colors.blue,
                ),
              ],
            ),
            // 2 item kanan
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final cartVM = Provider.of<CartViewModel>(
                      context,
                      listen: false,
                    );
                    cartVM.addToCart(currentItem);

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Item added to cart',
                          textAlign: TextAlign.center,
                        ),
                        contentPadding: EdgeInsets.all(20),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  iconSize: 28,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }
}
