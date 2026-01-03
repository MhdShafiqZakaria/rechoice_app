import 'package:flutter/material.dart';
import 'package:rechoice_app/components/user/add_product_dialog.dart';
import 'package:rechoice_app/components/user/my_product_card.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/viewmodels/items_view_model.dart';

class MyProductsTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (itemsVM.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (itemsVM.userItems.isEmpty) {
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
              onPressed: () async {
                final added = await showDialog<bool>(
                  context: context,
                  builder: (context) => AddProductDialog(userId: user.userID),
                );

                if (added == true) {
                  itemsVM.fetchUserItems(user.userID);
                }
              },
              label: Text('Add Product'),
              icon: Icon(Icons.add_circle, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (isOwnProfile)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${itemsVM.userItems.length} Products',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                TextButton(
                  onPressed: () async {
                    final added = await showDialog<bool>(
                      context: context,
                      builder: (context) =>
                          AddProductDialog(userId: user.userID),
                    );

                    if (added == true) {
                      itemsVM.fetchUserItems(user.userID);
                    }
                  },
                  child: Text('Add Product',style: TextStyle(color:Colors.blue),),

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
              itemCount: itemsVM.userItems.length,
              itemBuilder: (context, index) {
                final item = itemsVM.userItems[index];
                return MyProductCard(item: item);
              },
            ),
            onRefresh: () => itemsVM.fetchUserItems(user.userID),
          ),
        ),
      ],
    );
  }
}
