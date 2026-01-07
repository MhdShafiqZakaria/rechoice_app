import 'package:flutter/material.dart';
import 'package:rechoice_app/components/dashboard/category_btn.dart';
import 'package:rechoice_app/components/dashboard/product_card.dart';
import 'package:rechoice_app/components/ai_recognition_fab.dart';
import 'package:rechoice_app/models/model/category_model.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/services/authenticate.dart';
import 'package:rechoice_app/models/services/category_service.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';
import 'package:rechoice_app/models/services/item_service.dart';
import 'package:rechoice_app/models/services/listing_service.dart';
import 'package:rechoice_app/models/services/local_storage_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryID;
  List<Items> _allProducts = [];
  List<Items> _filteredProducts = [];
  List<ItemCategoryModel> _categories = [];
  bool _isLoading = true;
  String? _loadError;

  late ListingService _listingService;
  late CategoryService _categoryService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadData();
  }

  void _initializeServices() {
    final firestoreService = FirestoreService();
    final itemService = ItemService(FirestoreService(), LocalStorageService());
    _listingService = ListingService(firestoreService, itemService);
    _categoryService = CategoryService(firestoreService);
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _loadError = null;
      });

      // Fetch categories from Firebase
      _categories = await _categoryService.getAllCategories();
      print('DEBUG: Loaded ${_categories.length} categories');

      // Fetch all listings from Firebase (using getAllListings for debugging)
      // Note: Replace with getApprovedListings() once your items have proper moderation status
      final listings = await _listingService.getApprovedListings();
      _allProducts = listings.map((listing) => listing.item).toList();
      _filteredProducts = _allProducts;

      print('DEBUG: Loaded ${_allProducts.length} products');
      if (_allProducts.isNotEmpty) {
        print('DEBUG: First product: ${_allProducts[0].title}');
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Failed to load data: ${e.toString()}';
      });
      print('Error loading data: $e');
    }
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryID = categoryId;
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
  }

  void _searchProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        if (_selectedCategoryID == null) {
          _filteredProducts = _allProducts;
        } else {
          _filteredProducts = _allProducts
              .where((item) => item.category.categoryID == _selectedCategoryID)
              .toList();
        }
      } else {
        List<Items> baseList = _selectedCategoryID == null
            ? _allProducts
            : _allProducts
                  .where(
                    (item) => item.category.categoryID == _selectedCategoryID,
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
  }

  void _navigateToProductDetail(Items item) {
    Navigator.pushNamed(context, '/product', arguments: item);
  }

  void _showProfileMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 50,
        80,
        10,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile2');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    'My Profile',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () async {
              Navigator.pop(context);
              await authService.value.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red[600], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
        return Icons.brush;
      case 3:
        return Icons.book_outlined;
      case 4:
        return Icons.file_copy_outlined;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => AIRecognitionFAB.openRecognition(context),
        backgroundColor: Colors.blue,
        tooltip: 'AI Image Recognition',
        child: const Icon(Icons.image_search, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //Header
            Container(
              padding: EdgeInsets.all(16),
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
                borderRadius: BorderRadius.only(
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

                    //Logo
                    child: Center(
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ReChoice: UNIMAS Preloved Item',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Profile
                  GestureDetector(
                    onTap: () {
                      _showProfileMenu();
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.blue.shade700,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================== SEARCH BAR ==================
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

            // ================== CATEGORIES ROW ==================
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

            // ================== Categories ==================
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
                        icon: _iconForCategory(category.categoryID),
                        isSelected: _selectedCategoryID == category.categoryID,
                        onTap: () => _filterByCategory(category.categoryID),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ================== FEATURED ITEM ==================
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
                      Navigator.pushNamed(
                        context,
                        '/search',
                        arguments: _allProducts,
                      );
                    },
                    child: Text('See all'),
                  ),
                ],
              ),
            ),

            // ================== Featured Products Grid ==================
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading products...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _loadError != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade600,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                            ),
                            child: Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          items: _filteredProducts[index],
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
