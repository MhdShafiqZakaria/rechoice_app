import 'package:flutter/material.dart';
import 'package:rechoice_app/components/user/add_product_dialog.dart';
import 'package:rechoice_app/components/user/my_product_card.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/viewmodels/items_view_model.dart';

class MyProductsTab extends StatefulWidget {
  final ItemsViewModel itemsVM;
  final bool isOwnProfile;
  final Users user;
  const MyProductsTab({
    super.key,
    required this.itemsVM,
    required this.isOwnProfile,
    required this.user,
  });

  @override
  State<MyProductsTab> createState() => _MyProductsTabState();
}

class _MyProductsTabState extends State<MyProductsTab> {
  @override
  void initState() {
    super.initState();
    print('DEBUG: MyProductsTab initialized for user ID: ${widget.user.userID}');
  }

  void _handleAddProductClick() async {
    if (widget.user.isSeller) {
      // Show add product dialog for sellers
      final added = await showDialog<bool>(
        context: context,
        builder: (context) => AddProductDialog(userId: widget.user.userID),
      );

      if (added == true) {
        await widget.itemsVM.fetchUserItems(widget.user.userID);
        if (mounted) {
          setState(() {});
        }
      }
    } else if (widget.user.isBuyer) {
      // Show contact admin dialog for buyers
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Become a Seller'),
          content: const Text('Contact admin to become seller: admin@rechoice.com'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemsVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.itemsVM.userItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            ElevatedButton.icon(
              onPressed: _handleAddProductClick,
              label: const Text('Add Product'),
              icon: const Icon(Icons.add_circle, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (widget.isOwnProfile)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.itemsVM.userItems.length} Products',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                TextButton(
                  onPressed: _handleAddProductClick,
                  child: const Text('Add Product', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: widget.itemsVM.userItems.length,
              itemBuilder: (context, index) {
                final item = widget.itemsVM.userItems[index];
                return MyProductCard(item: item);
              },
            ),
            onRefresh: () => widget.itemsVM.fetchUserItems(widget.user.userID),
          ),
        ),
      ],
    );
  }
}
