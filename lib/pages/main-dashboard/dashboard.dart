import 'package:flutter/material.dart';
import 'package:rechoice_app/models/category.dart';
import 'package:rechoice_app/models/items.dart';
import 'package:rechoice_app/models/products.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Products _products = Products();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16), // PADDING GLOBAL PAGE
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================== APP BAR BOX ==================
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[900]!,
                      Colors.blue[700]!,
                      Colors.blue[500]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),

                    // left logo
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Image.asset('assets/images/logo.png'),
                    ),

                    const SizedBox(width: 12),

                    // app name
                    const Text(
                      'ReChoice: UNIMAS PreLoved Item',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    // right logo
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.blue, size: 18),
                      ),
                    ),

                    const SizedBox(width: 12),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================== SEARCH BAR ==================
              Container(
                height: 40,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ================== CATEGORIES ROW ==================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ================== Categories ==================
              Container(
                padding: const EdgeInsets.all(12),
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue[900]!,
                      Colors.blue[700]!,
                      Colors.blue[500]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryItem(context, category);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ================== FEATURED ITEM ==================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Featured Products',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ================== Featured Products Grid ==================
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 atas 2 bawah
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _products.products.length,
                itemBuilder: (context, index) {
                  final product = _products.products[index];
                  return _ProductCard(
                    imageAsset: product.imagePath,
                    name: product.title,
                    price: 'RM${product.price}',
                    product: product,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

//==================  BUILD CATEGORY ITEM WIDGET ==================
Widget _buildCategoryItem(BuildContext context, ItemCategory category) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, '/search');
    },
    child: Container(
      width: 70,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(
              _iconForCategory(category.categoryID),
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: TextStyle(fontSize: 12, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

//==================  ICON CATEGORY ITEM WIDGET ==================
IconData _iconForCategory(int id) {
  switch (id) {
    case 0:
      return Icons.water_drop;
    case 1:
      return Icons.checkroom;
    case 2:
      return Icons.checkroom;
    case 3:
      return Icons.checkroom;
    case 4:
      return Icons.checkroom;
    default:
      return Icons.category;
  }
}

// ================== CLASS featured product ==================
class _ProductCard extends StatelessWidget {
  final String imageAsset;
  final String name;
  final String price;
  final Items product;

  const _ProductCard({
    required this.imageAsset,
    required this.name,
    required this.price,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/product', arguments: product);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // product name
            Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // price
            Text(
              price,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
