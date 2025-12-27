import 'package:flutter/material.dart';
import 'package:rechoice_app/pages/main-dashboard/search_result.dart';
// ==================== MODELS ====================

// models/category.dart
class Category {
  final int categoryID;
  final String name;
  final String iconName;

  Category({
    required this.categoryID,
    required this.name,
    required this.iconName,
  });

  // Firebase ready
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryID: json['categoryID'],
      name: json['name'],
      iconName: json['iconName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'categoryID': categoryID, 'name': name, 'iconName': iconName};
  }
}

// models/item.dart
class Item {
  final int itemID;
  final String title;
  final Category category;
  final String brand;
  final String condition;
  final double price;
  final int quantity;
  final String description;
  final String status;
  final List<String> images;

  Item({
    required this.itemID,
    required this.title,
    required this.category,
    required this.brand,
    required this.condition,
    required this.price,
    required this.quantity,
    required this.description,
    required this.status,
    required this.images,
  });

  // Firebase ready
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemID: json['itemID'],
      title: json['title'],
      category: Category.fromJson(json['category']),
      brand: json['brand'],
      condition: json['condition'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      description: json['description'],
      status: json['status'],
      images: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'title': title,
      'category': category.toJson(),
      'brand': brand,
      'condition': condition,
      'price': price,
      'quantity': quantity,
      'description': description,
      'status': status,
      'images': images,
    };
  }
}

// models/user.dart
class User {
  final int userID;
  final String name;
  final String email;
  final String password;
  final String profilePic;
  final String bio;
  final double reputationScore;

  User({
    required this.userID,
    required this.name,
    required this.email,
    required this.password,
    required this.profilePic,
    required this.bio,
    required this.reputationScore,
  });

  // Firebase ready
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      profilePic: json['profilePic'],
      bio: json['bio'],
      reputationScore: json['reputationScore'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'password': password,
      'profilePic': profilePic,
      'bio': bio,
      'reputationScore': reputationScore,
    };
  }
}

// ==================== DUMMY DATA SERVICE ====================

// services/dummy_data.dart
class DummyDataService {
  static List<Category> getCategories() {
    return [
      Category(categoryID: 1, name: 'Phones', iconName: 'phone'),
      Category(categoryID: 2, name: 'Consoles', iconName: 'gamepad'),
      Category(categoryID: 3, name: 'Laptops', iconName: 'laptop'),
      Category(categoryID: 4, name: 'Cameras', iconName: 'camera'),
      Category(categoryID: 5, name: 'Audio', iconName: 'headphones'),
    ];
  }

  static List<Item> getFeaturedProducts() {
    final categories = getCategories();
    return [
      Item(
        itemID: 1,
        title: 'AirPods Pro',
        category: categories[4], // Audio
        brand: 'Apple',
        condition: 'Like New',
        price: 249.00,
        quantity: 1,
        description: 'Excellent condition AirPods Pro with charging case',
        status: 'available',
        images: [
          'https://via.placeholder.com/300x300/f0f0f0/333333?text=AirPods+Pro',
        ],
      ),
      Item(
        itemID: 2,
        title: 'iPad Pro 12.9',
        category: categories[2], // Laptops (tablets)
        brand: 'Apple',
        condition: 'Excellent',
        price: 1099.00,
        quantity: 1,
        description: 'iPad Pro 12.9 inch, Space Grey, 256GB',
        status: 'available',
        images: [
          'https://via.placeholder.com/300x300/2c2c2c/ffffff?text=iPad+Pro',
        ],
      ),
      Item(
        itemID: 3,
        title: 'Apple Watch Ultra',
        category: categories[0], // Phones (wearables)
        brand: 'Apple',
        condition: 'Good',
        price: 799.00,
        quantity: 1,
        description: 'Apple Watch Ultra with extra bands',
        status: 'available',
        images: [
          'https://via.placeholder.com/300x300/1a1a1a/ffffff?text=Watch+Ultra',
        ],
      ),
      Item(
        itemID: 4,
        title: 'Sony WH-1000XM5',
        category: categories[4], // Audio
        brand: 'Sony',
        condition: 'Like New',
        price: 399.00,
        quantity: 1,
        description: 'Premium noise-cancelling headphones',
        status: 'available',
        images: [
          'https://via.placeholder.com/300x300/333333/ffffff?text=Sony+WH-1000XM5',
        ],
      ),
      Item(
        itemID: 5,
        title: 'iPhone 15 Pro',
        category: categories[0], // Phones
        brand: 'Apple',
        condition: 'Excellent',
        price: 1299.00,
        quantity: 1,
        description: 'iPhone 15 Pro Max 256GB Natural Titanium',
        status: 'available',
        images: [
          'https://via.placeholder.com/300x300/4a4a4a/ffffff?text=iPhone+15',
        ],
      ),
      Item(
        itemID: 6,
        title: 'PS5 Console',
        category: categories[1], // Consoles
        brand: 'Sony',
        condition: 'Good',
        price: 549.00,
        quantity: 1,
        description: 'PlayStation 5 with controller',
        status: 'available',
        images: ['https://via.placeholder.com/300x300/003087/ffffff?text=PS5'],
      ),
      Item(
        itemID: 7,
        title: 'MacBook Pro M3',
        category: categories[2], // Laptops
        brand: 'Apple',
        condition: 'Like New',
        price: 2299.00,
        quantity: 1,
        description: 'MacBook Pro 14" M3 Pro chip',
        status: 'available',
        images: [
          'https://via.placeholder.com/300x300/000000/ffffff?text=MacBook',
        ],
      ),
      Item(
        itemID: 8,
        title: 'Canon EOS R6',
        category: categories[3], // Cameras
        brand: 'Canon',
        condition: 'Excellent',
        price: 1899.00,
        quantity: 1,
        description: 'Full-frame mirrorless camera',
        status: 'available',
        images: [
          'https://via.placeholder.com/300x300/1a1a1a/ffffff?text=Canon+R6',
        ],
      ),
    ];
  }

  static User getCurrentUser() {
    return User(
      userID: 1,
      name: 'John Doe',
      email: 'john@example.com',
      password: 'hashed_password',
      profilePic: 'https://via.placeholder.com/150',
      bio: 'Tech enthusiast and collector',
      reputationScore: 4.8,
    );
  }
}

// ==================== WIDGETS ====================

// widgets/category_button.dart

class CategoryButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade700 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// widgets/product_card.dart
class ProductCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RM${item.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MAIN DASHBOARD SCREEN ====================

// screens/dashboard.dart

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Item> _allProducts = [];
  List<Item> _filteredProducts = [];
  List<Category> _categories = [];
  int? _selectedCategoryId;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load dummy data (will be replaced with Firebase later)
    _categories = DummyDataService.getCategories();
    _allProducts = DummyDataService.getFeaturedProducts();
    _filteredProducts = _allProducts;
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId == null) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((item) => item.category.categoryID == categoryId)
            .toList();
      }
      // Apply search filter if exists
      if (_searchController.text.isNotEmpty) {
        _searchProducts(_searchController.text);
      }
    });

    if (categoryId != null) {
      Category category = _categories.firstWhere(
        (c) => c.categoryID == categoryId,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            categoryId: categoryId,
            categoryName: category.name,
            searchResults: _filteredProducts,
          ),
        ),
      );
    }
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_selectedCategoryId == null) {
          _filteredProducts = _allProducts;
        } else {
          _filteredProducts = _allProducts
              .where((item) => item.category.categoryID == _selectedCategoryId)
              .toList();
        }
      } else {
        List<Item> baseList = _selectedCategoryId == null
            ? _allProducts
            : _allProducts
                  .where(
                    (item) => item.category.categoryID == _selectedCategoryId,
                  )
                  .toList();

        _filteredProducts = baseList
            .where(
              (item) =>
                  item.title.toLowerCase().contains(query.toLowerCase()) ||
                  item.brand.toLowerCase().contains(query.toLowerCase()) ||
                  item.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
    // Navigate to search results bila ada search query
    if (query.isNotEmpty && _filteredProducts.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultScreen(
            searchQuery: query,
            searchResults: _filteredProducts,
          ),
        ),
      );
    }
  }

  void _navigateToProductDetail(Item item) {
    // TODO: Navigate to product detail page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${item.title}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'phone':
        return Icons.smartphone;
      case 'gamepad':
        return Icons.videogame_asset;
      case 'laptop':
        return Icons.laptop_mac;
      case 'camera':
        return Icons.camera_alt;
      case 'headphones':
        return Icons.headphones;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '2ND',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'ReChoice: UNIMAS Preloved Item',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _searchProducts,
                decoration: InputDecoration(
                  hintText: 'Search the entire shop',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _filterByCategory(null),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories List
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CategoryButton(
                        name: category.name,
                        icon: _getCategoryIcon(category.iconName),
                        isSelected: _selectedCategoryId == category.categoryID,
                        onTap: () => _filterByCategory(category.categoryID),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Featured Products Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SearchResultScreen(searchResults: _allProducts),
                        ),
                      );
                    },
                    child: Text('See all'),
                  ),
                ],
              ),
            ),

            // Products Grid
            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          item: _filteredProducts[index],
                          onTap: () => _navigateToProductDetail(
                            _filteredProducts[index],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: (index) {
            setState(() {
              _selectedNavIndex = index;
            });
            // TODO: Navigate to respective pages
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
