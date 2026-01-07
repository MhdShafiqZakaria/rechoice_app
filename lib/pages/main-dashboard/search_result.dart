import 'package:flutter/material.dart';
import 'package:rechoice_app/components/dashboard/product_card.dart';
import 'package:rechoice_app/components/dashboard/search_arguments.dart';
import 'package:rechoice_app/models/model/items_model.dart';

class SearchResult extends StatefulWidget {
  final String? searchQuery;
  final int? categoryId;
  final String? categoryName;
  final List<Items> searchResults;
  const SearchResult({
    super.key,
    this.searchQuery,
    this.categoryId,
    this.categoryName,
    required this.searchResults,
  });

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  late List<Items> _displayedResults;
  late List<Items> _originalResults;
  String _sortBy = 'default';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is SearchArguments) {
        _originalResults = List.from(args.searchResults);
        _displayedResults = List.from(args.searchResults);
      } else if (args is List<Items>) {
        _originalResults = List.from(args);
        _displayedResults = List.from(args);
      } else {
        _originalResults = List.from(widget.searchResults);
        _displayedResults = List.from(widget.searchResults);
      }
      _initialized = true;
    }
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
        case 'default':
          _displayedResults = List.from(_originalResults);
          break;
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  void _navigateToProductDetail(Items item) {
    Navigator.pushNamed(context, '/product', arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until initialized
    if (!_initialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          iconSize: 20,
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.searchQuery != null
              ? 'Search Results'
              : widget.categoryName ?? 'Products',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortBottomSheet,
            icon: const Icon(Icons.sort, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_displayedResults.length} products found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: _showSortBottomSheet,
                  icon: Icon(
                    Icons.filter_list,
                    size: 18,
                    color: Colors.blue.shade700,
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
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 8),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _displayedResults.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        items: _displayedResults[index],
                        onTap: () =>
                            _navigateToProductDetail(_displayedResults[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
