// screens/search_result.dart
import 'package:flutter/material.dart';
import 'package:rechoice_app/pages/main-dashboard/dashboard2.dart';

// Import models and widgets from dashboard.dart
// Assuming these are already available from previous file

class SearchResultScreen extends StatefulWidget {
  final String? searchQuery;
  final int? categoryId;
  final String? categoryName;
  final List<Item> searchResults;

  const SearchResultScreen({
    super.key,
    this.searchQuery,
    this.categoryId,
    this.categoryName,
    required this.searchResults,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  late List<Item> _displayedResults;
  String _sortBy = 'default'; // default, price_low, price_high, name

  @override
  void initState() {
    super.initState();
    _displayedResults = List.from(widget.searchResults);
  }

  void _sortResults(String sortType) {
    setState(() {
      _sortBy = sortType;
      switch (sortType) {
        case 'price_low':
          _displayedResults.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _displayedResults.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name':
          _displayedResults.sort((a, b) => a.title.compareTo(b.title));
          break;
        default:
          _displayedResults = List.from(widget.searchResults);
      }
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildSortOption('Default', 'default'),
              _buildSortOption('Price: Low to High', 'price_low'),
              _buildSortOption('Price: High to Low', 'price_high'),
              _buildSortOption('Name: A to Z', 'name'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value) {
    return ListTile(
      title: Text(label),
      trailing: _sortBy == value
          ? Icon(Icons.check, color: Colors.blue.shade700)
          : null,
      onTap: () {
        _sortResults(value);
        Navigator.pop(context);
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.searchQuery != null
              ? 'Searched Result'
              : widget.categoryName ?? 'Products',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: _showSortBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search query info banner (if search was performed)
          if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Text(
                'Results for "${widget.searchQuery}"',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Results count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_displayedResults.length} products found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showSortBottomSheet,
                  icon: Icon(Icons.filter_list, 
                    size: 18, 
                    color: Colors.blue.shade700
                  ),
                  label: Text(
                    'Sort',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: _displayedResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _displayedResults.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_displayedResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Item item) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  // Condition badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getConditionColor(item.condition),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.condition,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Product Info
            Expanded(
              child: Padding(
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
                    const SizedBox(height: 4),
                    Text(
                      item.brand,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
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
            ),
          ],
        ),
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'like new':
        return Colors.green.shade600;
      case 'excellent':
        return Colors.blue.shade600;
      case 'good':
        return Colors.orange.shade600;
      case 'fair':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}

// ==================== NAVIGATION HELPER ====================
// Add this to your dashboard.dart to navigate to search results

extension NavigationHelper on State {
  void navigateToSearchResults({
    String? searchQuery,
    int? categoryId,
    String? categoryName,
    required List<Item> results,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(
          searchQuery: searchQuery,
          categoryId: categoryId,
          categoryName: categoryName,
          searchResults: results,
        ),
      ),
    );
  }
}

