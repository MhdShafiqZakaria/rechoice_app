import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16), // PADDING GLOBAL PAGE
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================== APPBAR BOX ==================
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
                      'ReChoice: Unimas Preloved Item',
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CategoryItem(
                      icon: Icons.phone_android,
                      label: 'Phones',
                      onTap: () {},
                    ),
                    _CategoryItem(
                      icon: Icons.laptop,
                      label: 'Laptops',
                      onTap: () {},
                    ),
                    _CategoryItem(
                      icon: Icons.sports_esports,
                      label: 'Consoles',
                      onTap: () {},
                    ),
                    _CategoryItem(
                      icon: Icons.camera,
                      label: 'Cameras',
                      onTap: () {},
                    ),
                    _CategoryItem(
                      icon: Icons.headphones,
                      label: 'Audio',
                      onTap: () {},
                    ),
                  ],
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
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, // 2 atas 2 bawah
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
                children: const [
                  _ProductCard(
                    imageAsset: 'assets/images/IPAD.png',
                    name: 'Product 1',
                    price: '\$100',
                  ),
                  _ProductCard(
                    imageAsset: 'assets/images/IPAD.png',
                    name: 'Product 2',
                    price: '\$200',
                  ),
                  _ProductCard(
                    imageAsset: 'assets/images/IPAD.png',
                    name: 'Product 3',
                    price: '\$150',
                  ),
                  _ProductCard(
                    imageAsset: 'assets/images/IPAD.png',
                    name: 'Product 4',
                    price: '\$180',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // // ================== BOTTOM NAVIGATION BAR ==================
      // bottomNavigationBar: Container(
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       colors: [Colors.blue[900]!, Colors.blue[700]!, Colors.blue[500]!],
      //       begin: Alignment.centerLeft,
      //       end: Alignment.centerRight,
      //     ),
      //   ),
      //   child: BottomNavigationBar(
      //     type: BottomNavigationBarType.fixed,
      //     backgroundColor: Colors.transparent,
      //     selectedItemColor: Colors.white,
      //     unselectedItemColor: Colors.white70,
      //     selectedFontSize: 16.0,
      //     unselectedFontSize: 14.0,
      //     iconSize: 28.0,
      //     currentIndex: 0,
      //     elevation: 0,
      //     items: const [
      //       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.shopping_bag_outlined),
      //         label: 'Shop',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.shopping_cart_outlined),
      //         label: 'Order',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.person_outline),
      //         label: 'Profile',
      //       ),
      //     ],
      //     onTap: (index) {
      //       setState(() {
              
      //       });
      //     },
      //   ),
      // ),
    );
  }
}

// ================== CLASS CATEGORY ITEM WIDGET ==================
class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _CategoryItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.blue, size: 18),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ================== CLASS featured product ==================
class _ProductCard extends StatelessWidget {
  final String imageAsset;
  final String name;
  final String price;

  const _ProductCard({
    required this.imageAsset,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('$name tapped');
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
