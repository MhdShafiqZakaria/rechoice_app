import 'package:flutter/foundation.dart';
import 'package:rechoice_app/models/model/items_model.dart';
import 'package:rechoice_app/models/model/listing_model.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';
import 'package:rechoice_app/models/services/item_service.dart';

enum ListingLoadingState { idle, loading, loaded, error }

class ListingViewModel extends ChangeNotifier {
  final ItemService _itemService;
  final FirestoreService _firestoreService;

  // State management
  ListingLoadingState _state = ListingLoadingState.idle;
  String? _errorMessage;

  // Listings data
  List<ListingModel> _listings = [];
  List<ListingModel> _filteredListings = [];

  // Seller statistics
  int _totalListings = 0;
  int _totalPurchases = 0;
  int _totalSales = 0;
  double _reputationScore = 0.0;
  Users? _sellerInfo;

  // Filter state
  String _searchQuery = '';
  ModerationStatus? _statusFilter;

  ListingViewModel({
    required ItemService itemService,
    required FirestoreService firestoreService,
  }) : _itemService = itemService,
       _firestoreService = firestoreService;

  // ==================== GETTERS ====================

  ListingLoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ListingLoadingState.loading;
  bool get hasError => _state == ListingLoadingState.error;

  List<ListingModel> get listings => List.unmodifiable(_listings);
  List<ListingModel> get filteredListings =>
      List.unmodifiable(_filteredListings);

  // Seller statistics getters
  int get totalListings => _totalListings;
  int get totalPurchases => _totalPurchases;
  int get totalSales => _totalSales;
  double get reputationScore => _reputationScore;
  Users? get sellerInfo => _sellerInfo;

  // Filter getters
  String get searchQuery => _searchQuery;
  ModerationStatus? get statusFilter => _statusFilter;

  // ==================== FETCH OPERATIONS ====================

  /// Fetch seller statistics and listings
  Future<void> fetchSellerListings(int sellerID) async {
    _setState(ListingLoadingState.loading);
    try {
      // Fetch seller info
      final sellerDoc = await _firestoreService.getUser('user_$sellerID');
      if (!sellerDoc.exists) {
        _setError('Seller not found');
        return;
      }

      final sellerData = Map<String, dynamic>.from(
        sellerDoc.data() as Map<String, dynamic>,
      );
      _sellerInfo = Users.fromJson(sellerData);

      // Extract seller statistics
      _totalListings = _sellerInfo?.totalListings ?? 0;
      _totalPurchases = _sellerInfo?.totalPurchases ?? 0;
      _totalSales = _sellerInfo?.totalSales ?? 0;
      _reputationScore = _sellerInfo?.reputationScore ?? 0.0;

      // Fetch seller's items
      final items = await _itemService.getItemsBySeller(sellerID);

      // Create listings by combining items with seller info
      _listings = items.map((item) {
        return ListingModel(
          item: item,
          seller: _sellerInfo!,
          sellerID: sellerID,
        );
      }).toList();

      _filteredListings = _listings;
      _setState(ListingLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load seller listings: $e');
    }
  }

  /// Fetch all listings across all sellers
  Future<void> fetchAllListings() async {
    _setState(ListingLoadingState.loading);
    try {
      final items = await _itemService.getAllItems();
      _listings = [];

      for (final item in items) {
        try {
          final sellerDoc = await _firestoreService.getUser(
            'user_${item.sellerID}',
          );
          if (sellerDoc.exists) {
            final sellerData = Map<String, dynamic>.from(
              sellerDoc.data() as Map<String, dynamic>,
            );
            final seller = Users.fromJson(sellerData);

            _listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          debugPrint('Error fetching seller for item ${item.itemID}: $e');
        }
      }

      _filteredListings = _listings;
      _setState(ListingLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load listings: $e');
    }
  }

  /// Fetch approved listings only
  Future<void> fetchApprovedListings() async {
    _setState(ListingLoadingState.loading);
    try {
      final items = await _itemService.getApprovedItems();
      _listings = [];

      for (final item in items) {
        try {
          final sellerDoc = await _firestoreService.getUser(
            'user_${item.sellerID}',
          );
          if (sellerDoc.exists) {
            final sellerData = Map<String, dynamic>.from(
              sellerDoc.data() as Map<String, dynamic>,
            );
            final seller = Users.fromJson(sellerData);

            _listings.add(
              ListingModel(item: item, seller: seller, sellerID: item.sellerID),
            );
          }
        } catch (e) {
          debugPrint('Error fetching seller for item ${item.itemID}: $e');
        }
      }

      _filteredListings = _listings;
      _setState(ListingLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load approved listings: $e');
    }
  }

  // ==================== SEARCH & FILTER ====================

  /// Search listings by title or seller name
  void searchListings(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredListings = _listings;
      notifyListeners();
      return;
    }

    _filteredListings = _listings.where((listing) {
      final titleMatch = listing.itemTitle.toLowerCase().contains(
        query.toLowerCase(),
      );
      final sellerMatch = listing.sellerName.toLowerCase().contains(
        query.toLowerCase(),
      );
      return titleMatch || sellerMatch;
    }).toList();

    notifyListeners();
  }

  /// Filter listings by moderation status
  void filterByStatus(ModerationStatus? status) {
    _statusFilter = status;

    if (status == null) {
      _filteredListings = _listings;
    } else {
      _filteredListings = _listings.where((listing) {
        return listing.moderationStatus == status;
      }).toList();
    }

    notifyListeners();
  }

  /// Filter listings by seller rating
  List<ListingModel> getListingsBySellerRating(double minRating) {
    return _listings.where((listing) {
      return listing.sellerRating >= minRating;
    }).toList();
  }

  /// Filter available listings only
  List<ListingModel> getAvailableListings() {
    return _listings.where((listing) => listing.isAvailable).toList();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _filteredListings = _listings;
    notifyListeners();
  }

  // ==================== STATISTICS ====================

  /// Get total views across all listings
  int getTotalViews() {
    return _listings.fold<int>(
      0,
      (sum, listing) => sum + listing.itemViewCount,
    );
  }

  /// Get total favorites across all listings
  int getTotalFavorites() {
    return _listings.fold<int>(
      0,
      (sum, listing) => sum + listing.itemFavoriteCount,
    );
  }

  /// Get average item price
  double getAveragePrice() {
    if (_listings.isEmpty) return 0.0;
    final total = _listings.fold<double>(
      0,
      (sum, listing) => sum + listing.itemPrice,
    );
    return total / _listings.length;
  }

  /// Get count by moderation status
  int getCountByStatus(ModerationStatus status) {
    return _listings
        .where((listing) => listing.moderationStatus == status)
        .length;
  }

  /// Get seller performance summary
  Map<String, dynamic> getSellerPerformanceSummary() {
    return {
      'totalListings': _totalListings,
      'totalPurchases': _totalPurchases,
      'totalSales': _totalSales,
      'reputationScore': _reputationScore,
      'totalViews': getTotalViews(),
      'totalFavorites': getTotalFavorites(),
      'averagePrice': getAveragePrice(),
      'approvedCount': getCountByStatus(ModerationStatus.approved),
      'pendingCount': getCountByStatus(ModerationStatus.pending),
      'rejectedCount': getCountByStatus(ModerationStatus.rejected),
      'availableCount': getAvailableListings().length,
    };
  }

  // ==================== SORTING ====================

  /// Sort listings by price
  void sortByPrice({bool ascending = true}) {
    _filteredListings.sort(
      (a, b) => ascending
          ? a.itemPrice.compareTo(b.itemPrice)
          : b.itemPrice.compareTo(a.itemPrice),
    );
    notifyListeners();
  }

  /// Sort listings by seller rating
  void sortBySellerRating({bool highest = true}) {
    _filteredListings.sort(
      (a, b) => highest
          ? b.sellerRating.compareTo(a.sellerRating)
          : a.sellerRating.compareTo(b.sellerRating),
    );
    notifyListeners();
  }

  /// Sort listings by view count
  void sortByPopularity() {
    _filteredListings.sort(
      (a, b) => b.itemViewCount.compareTo(a.itemViewCount),
    );
    notifyListeners();
  }

  // ==================== HELPER METHODS ====================

  ListingModel? getListingById(int itemID) {
    try {
      return _listings.firstWhere((listing) => listing.item.itemID == itemID);
    } catch (e) {
      return null;
    }
  }

  List<ListingModel> getListingsBySeller(int sellerID) {
    return _listings.where((listing) => listing.sellerID == sellerID).toList();
  }

  // ==================== PRIVATE HELPERS ====================

  void _setState(ListingLoadingState newState) {
    _state = newState;
    if (newState != ListingLoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = ListingLoadingState.error;
    _errorMessage = error;
    notifyListeners();
    debugPrint('ListingViewModel Error: $error');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
