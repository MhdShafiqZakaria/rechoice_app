import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/services/item_service.dart';

enum ItemsLoadingState { idle, loading, loaded, error }

class ItemsViewModel extends ChangeNotifier {
  final ItemService _itemService;

  // State management
  ItemsLoadingState _state = ItemsLoadingState.idle;
  String? _errorMessage;

  // Item lists
  List<Items> _allItems = [];
  List<Items> _approvedItems = [];
  List<Items> _pendingItems = [];
  List<Items> _userItems = [];
  List<Items> _filteredItems = [];

  // Search and filter state
  String _searchQuery = '';
  int? _selectedCategoryId;
  String? _selectedCondition;
  double? _minPrice;
  double? _maxPrice;

  ItemsViewModel(this._itemService);

  // ==================== GETTERS ====================

  ItemsLoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ItemsLoadingState.loading;
  bool get hasError => _state == ItemsLoadingState.error;

  List<Items> get allItems => List.unmodifiable(_allItems);
  List<Items> get approvedItems => List.unmodifiable(_approvedItems);
  List<Items> get pendingItems => List.unmodifiable(_pendingItems);
  List<Items> get userItems => List.unmodifiable(_userItems);
  List<Items> get filteredItems => List.unmodifiable(_filteredItems);

  int get totalItemCount => _allItems.length;
  int get approvedItemCount => _approvedItems.length;
  int get pendingItemCount => _pendingItems.length;

  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get selectedCondition => _selectedCondition;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  // ==================== FETCH OPERATIONS ====================

  Future<void> fetchAllItems() async {
    _setState(ItemsLoadingState.loading);
    try {
      _allItems = await _itemService.getAllItems();
      _setState(ItemsLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load items: $e');
    }
  }

  Future<void> fetchApprovedItems() async {
    _setState(ItemsLoadingState.loading);
    try {
      _approvedItems = await _itemService.getApprovedItems();
      _filteredItems = _approvedItems;
      _setState(ItemsLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load approved items: $e');
    }
  }

  Future<void> fetchPendingItems() async {
    _setState(ItemsLoadingState.loading);
    try {
      _pendingItems = await _itemService.getPendingItems();
      _setState(ItemsLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load pending items: $e');
    }
  }

  Future<void> fetchUserItems(int userId) async {
    print('DEBUG: Starting fetchUserItems for userId: $userId');
    _setState(ItemsLoadingState.loading);
    try {
      print('DEBUG: Calling _itemService.getItemsBySeller');
      _userItems = await _itemService.getItemsBySeller(userId);
      print('DEBUG: Fetched ${_userItems.length} items for userId: $userId');
      _setState(ItemsLoadingState.loaded);
    } catch (e) {
      print('DEBUG: Error in fetchUserItems: $e');
      _setError('Failed to load user items: $e');
    }
  }

  Future<Items?> fetchItemById(String itemId) async {
    try {
      return await _itemService.getItemById(itemId);
    } catch (e) {
      _setError('Failed to load item: $e');
      return null;
    }
  }

  Future<void> fetchItemsByCategory(int categoryId) async {
    _setState(ItemsLoadingState.loading);
    try {
      _filteredItems = await _itemService.getItemsByCategory(categoryId);
      _setState(ItemsLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load category items: $e');
    }
  }

  // ==================== CRUD OPERATIONS ====================

  Future<String?> createItem(Items item) async {
    try {
      final itemId = await _itemService.createItem(item);
      await fetchUserItems(item.sellerID);
      return itemId;
    } catch (e) {
      _setError('Failed to create item: $e');
      return null;
    }
  }

  Future<bool> updateItem(String itemId, Map<String, dynamic> updates) async {
    try {
      await _itemService.updateItem(itemId, updates);

      // Refresh relevant lists
      final updatedItem = await _itemService.getItemById(itemId);
      if (updatedItem != null) {
        _updateItemInLists(itemId, updatedItem);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update item: $e');
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    try {
      await _itemService.deleteItem(itemId);
      _removeItemFromLists(itemId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete item: $e');
      return false;
    }
  }

  Future<bool> softDeleteItem(String itemId) async {
    try {
      await _itemService.softDeleteItem(itemId);
      _removeItemFromLists(itemId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove item: $e');
      return false;
    }
  }

  // ==================== MODERATION OPERATIONS ====================

  Future<bool> approveItem(String itemId, int moderatorId) async {
    try {
      await _itemService.updateModerationStatus(
        itemId: itemId,
        status: ModerationStatus.approved,
        moderatedBy: moderatorId,
      );
      await fetchPendingItems();
      await fetchApprovedItems();
      return true;
    } catch (e) {
      _setError('Failed to approve item: $e');
      return false;
    }
  }

  Future<bool> rejectItem(String itemId, int moderatorId, String reason) async {
    try {
      await _itemService.updateModerationStatus(
        itemId: itemId,
        status: ModerationStatus.rejected,
        moderatedBy: moderatorId,
        rejectionReason: reason,
      );
      await fetchPendingItems();
      return true;
    } catch (e) {
      _setError('Failed to reject item: $e');
      return false;
    }
  }

  Future<bool> flagItem(String itemId, int moderatorId) async {
    try {
      await _itemService.updateModerationStatus(
        itemId: itemId,
        status: ModerationStatus.flagged,
        moderatedBy: moderatorId,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to flag item: $e');
      return false;
    }
  }

  // ==================== QUANTITY OPERATIONS ====================

  Future<bool> updateQuantity(String itemId, int newQuantity) async {
    try {
      await _itemService.updateQuantity(itemId, newQuantity);

      final updatedItem = await _itemService.getItemById(itemId);
      if (updatedItem != null) {
        _updateItemInLists(itemId, updatedItem);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update quantity: $e');
      return false;
    }
  }

  // ==================== ENGAGEMENT OPERATIONS ====================

  Future<void> incrementViewCount(String itemId) async {
    try {
      await _itemService.incrementViewCount(itemId);
      // No need to refresh entire list for view count
    } catch (e) {
      // Silent fail for view count
      debugPrint('Failed to increment view count: $e');
    }
  }

  Future<void> incrementFavoriteCount(String itemId) async {
    try {
      await _itemService.incrementFavoriteCount(itemId);
    } catch (e) {
      debugPrint('Failed to increment favorite count: $e');
    }
  }

  Future<void> decrementFavoriteCount(String itemId) async {
    try {
      await _itemService.decrementFavoriteCount(itemId);
    } catch (e) {
      debugPrint('Failed to decrement favorite count: $e');
    }
  }

  // ==================== SEARCH & FILTER ====================

  Future<void> searchItems(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredItems = _approvedItems;
      notifyListeners();
      return;
    }

    _setState(ItemsLoadingState.loading);
    try {
      _filteredItems = await _itemService.searchItems(query);
      _setState(ItemsLoadingState.loaded);
    } catch (e) {
      _setError('Search failed: $e');
    }
  }

  Future<void> applyFilters({
    int? categoryId,
    String? condition,
    double? minPrice,
    double? maxPrice,
  }) async {
    _selectedCategoryId = categoryId;
    _selectedCondition = condition;
    _minPrice = minPrice;
    _maxPrice = maxPrice;

    _setState(ItemsLoadingState.loading);
    try {
      _filteredItems = await _itemService.filterItems(
        categoryId: categoryId,
        condition: condition,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      _setState(ItemsLoadingState.loaded);
    } catch (e) {
      _setError('Filter failed: $e');
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _selectedCondition = null;
    _minPrice = null;
    _maxPrice = null;
    _filteredItems = _approvedItems;
    notifyListeners();
  }

  // ==================== SORTING ====================

  void sortByPrice({bool ascending = true}) {
    _filteredItems.sort(
      (a, b) =>
          ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price),
    );
    notifyListeners();
  }

  void sortByDate({bool newest = true}) {
    _filteredItems.sort(
      (a, b) => newest
          ? b.postedDate.compareTo(a.postedDate)
          : a.postedDate.compareTo(b.postedDate),
    );
    notifyListeners();
  }

  void sortByPopularity() {
    _filteredItems.sort(
      (a, b) => b.popularityScore.compareTo(a.popularityScore),
    );
    notifyListeners();
  }

  // ==================== IMAGE UPLOAD ====================

  Future<String?> uploadItemImage(File imageFile) async {
    try {
      // Generate temporary ID for upload path
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrl = await _itemService.uploadItemImage(imageFile, tempId);
      return imageUrl;
    } catch (e) {
      _setError('Failed to upload image: $e');
      return null;
    }
  }

  Future<List<String>?> uploadMultipleItemImages(List<File> imageFiles) async {
    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final imageUrls = await _itemService.uploadMultipleImages(
        imageFiles,
        tempId,
      );
      return imageUrls;
    } catch (e) {
      _setError('Failed to upload images: $e');
      return null;
    }
  }

  Future<void> deleteItemImage(String imageUrl) async {
    try {
      await _itemService.deleteItemImage(imageUrl);
    } catch (e) {
      debugPrint('Failed to delete image: $e');
    }
  }

  // ==================== ENHANCED CREATE WITH IMAGE ====================

  Future<String?> createItemWithImage(Items item, File imageFile) async {
    try {
      // Validate inputs
      if (item.sellerID == null || item.sellerID == 0) {
        throw Exception('Invalid seller ID: ${item.sellerID}');
      }
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: ${imageFile.path}');
      }

      debugPrint('Step 1: Creating item for seller ${item.sellerID}');
      final itemId = await _itemService.createItem(item);
      if (itemId == null || itemId.isEmpty) {
        throw Exception('Failed to create item: No ID returned');
      }
      debugPrint('Item created with ID: $itemId');

      debugPrint('Step 2: Uploading image to Firebase Storage for item $itemId');
      final imageUrl = await _itemService.uploadItemImage(imageFile, itemId);
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Failed to upload image: No URL returned');
      }
      debugPrint('Image uploaded to Firebase Storage: $imageUrl');

      debugPrint('Step 3: Updating item with Firebase Storage image URL');
      await _itemService.updateItem(itemId, {'image': imageUrl});
      debugPrint('Item updated successfully with image URL');

      debugPrint('Step 4: Refreshing user items for seller ${item.sellerID}');
      await fetchUserItems(item.sellerID);
      debugPrint('Lists refreshed');

      return itemId;
    } catch (e) {
      debugPrint('Error in createItemWithImage: $e'); // Log the full error
      _setError('Failed to create item with image: $e');
      return null;
    }
  }

  // ==================== HELPER METHODS ====================

  Items? getItemById(String itemId) {
    try {
      return _allItems.firstWhere((item) => item.itemID.toString() == itemId);
    } catch (e) {
      return null;
    }
  }

  List<Items> getNewItems() {
    return _approvedItems.where((item) => item.isNew).toList();
  }

  List<Items> getPopularItems() {
    return _approvedItems.where((item) => item.isPopular).toList();
  }

  List<Items> getItemsByCondition(String condition) {
    return _approvedItems.where((item) => item.condition == condition).toList();
  }

  bool isItemAvailable(String itemId) {
    final item = getItemById(itemId);
    return item?.isAvailable ?? false;
  }

  // ==================== PRIVATE HELPERS ====================

  void _setState(ItemsLoadingState newState) {
    _state = newState;
    if (newState != ItemsLoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = ItemsLoadingState.error;
    _errorMessage = error;
    notifyListeners();
    debugPrint('ItemsViewModel Error: $error');
  }

  void _updateItemInLists(String itemId, Items updatedItem) {
    // Update in all items
    final allIndex = _allItems.indexWhere(
      (item) => item.itemID.toString() == itemId,
    );
    if (allIndex != -1) _allItems[allIndex] = updatedItem;

    // Update in approved items
    final approvedIndex = _approvedItems.indexWhere(
      (item) => item.itemID.toString() == itemId,
    );
    if (approvedIndex != -1) _approvedItems[approvedIndex] = updatedItem;

    // Update in filtered items
    final filteredIndex = _filteredItems.indexWhere(
      (item) => item.itemID.toString() == itemId,
    );
    if (filteredIndex != -1) _filteredItems[filteredIndex] = updatedItem;

    // Update in user items
    final userIndex = _userItems.indexWhere(
      (item) => item.itemID.toString() == itemId,
    );
    if (userIndex != -1) _userItems[userIndex] = updatedItem;
  }

  void _removeItemFromLists(String itemId) {
    _allItems.removeWhere((item) => item.itemID.toString() == itemId);
    _approvedItems.removeWhere((item) => item.itemID.toString() == itemId);
    _pendingItems.removeWhere((item) => item.itemID.toString() == itemId);
    _filteredItems.removeWhere((item) => item.itemID.toString() == itemId);
    _userItems.removeWhere((item) => item.itemID.toString() == itemId);
  }

  // ==================== STREAM SUPPORT ====================

  void listenToApprovedItems() {
    _itemService.streamApprovedItems().listen(
      (items) {
        _approvedItems = items;
        if (_filteredItems.isEmpty || _searchQuery.isEmpty) {
          _filteredItems = items;
        }
        notifyListeners();
      },
      onError: (error) {
        _setError('Stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}
