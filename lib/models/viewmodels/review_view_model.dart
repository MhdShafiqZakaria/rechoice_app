import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/review_model.dart';

enum ReviewLoadingState { idle, loading, loaded, error }

class ReviewViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  // State management
  ReviewLoadingState _state = ReviewLoadingState.idle;
  String? _errorMessage;

  // Review lists
  List<Review> _allReviews = [];
  List<Review> _itemReviews = [];
  List<Review> _userReviews = [];

  ReviewViewModel({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== GETTERS ====================

  ReviewLoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ReviewLoadingState.loading;
  bool get hasError => _state == ReviewLoadingState.error;

  List<Review> get allReviews => List.unmodifiable(_allReviews);
  List<Review> get itemReviews => List.unmodifiable(_itemReviews);
  List<Review> get userReviews => List.unmodifiable(_userReviews);

  int get totalReviewCount => _allReviews.length;

  // ==================== FETCH OPERATIONS ====================

  Future<void> fetchAllReviews() async {
    _setState(ReviewLoadingState.loading);
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .orderBy('date', descending: true)
          .get();

      _allReviews = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Review.fromJson(data);
          })
          .toList();

      _setState(ReviewLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load reviews: $e');
    }
  }

  Future<void> fetchReviewsForItem(int itemID) async {
    _setState(ReviewLoadingState.loading);
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('itemID', isEqualTo: itemID)
          .orderBy('date', descending: true)
          .get();

      _itemReviews = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Review.fromJson(data);
          })
          .toList();

      _setState(ReviewLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load item reviews: $e');
    }
  }

  Future<void> fetchReviewsByUser(int userID) async {
    _setState(ReviewLoadingState.loading);
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userID', isEqualTo: userID)
          .orderBy('date', descending: true)
          .get();

      _userReviews = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Review.fromJson(data);
          })
          .toList();

      _setState(ReviewLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load user reviews: $e');
    }
  }

  Future<Review?> fetchReviewById(String reviewId) async {
    try {
      final doc = await _firestore.collection('reviews').doc(reviewId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return Review.fromJson(data);
    } catch (e) {
      _setError('Failed to load review: $e');
      return null;
    }
  }

  // ==================== CREATE OPERATIONS ====================

  Future<String?> createReview(Review review) async {
    try {
      // Validate review
      if (review.userID == 0) {
        throw Exception('Invalid user ID');
      }
      if (review.itemID == 0) {
        throw Exception('Invalid item ID');
      }
      if (review.rating < 1 || review.rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }
      if (review.comment.trim().isEmpty) {
        throw Exception('Review comment cannot be empty');
      }

      // Check if user already reviewed this item
      final existingReview = await _checkExistingReview(
        review.userID,
        review.itemID,
      );

      if (existingReview != null) {
        _setError('You have already reviewed this item');
        return null;
      }

      // Create review in Firestore
      final docRef = await _firestore.collection('reviews').add(
            review.toJson(),
          );

      // Refresh item reviews if currently viewing this item
      if (_itemReviews.isNotEmpty &&
          _itemReviews.first.itemID == review.itemID) {
        await fetchReviewsForItem(review.itemID);
      }

      return docRef.id;
    } catch (e) {
      _setError('Failed to create review: $e');
      return null;
    }
  }

  // ==================== UPDATE OPERATIONS ====================

  Future<bool> updateReview(String reviewId, Map<String, dynamic> updates) async {
    try {
      // Only allow updating rating and comment
      final allowedFields = ['rating', 'comment'];
      final filteredUpdates = Map<String, dynamic>.fromEntries(
        updates.entries.where((e) => allowedFields.contains(e.key)),
      );

      if (filteredUpdates.isEmpty) {
        throw Exception('No valid fields to update');
      }

      await _firestore.collection('reviews').doc(reviewId).update(
            filteredUpdates,
          );

      // Update local lists
      final updatedReview = await fetchReviewById(reviewId);
      if (updatedReview != null) {
        _updateReviewInLists(reviewId, updatedReview);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update review: $e');
      return false;
    }
  }

  // ==================== DELETE OPERATIONS ====================

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
      _removeReviewFromLists(reviewId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete review: $e');
      return false;
    }
  }

  Future<bool> deleteReviewsByItem(int itemID) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('itemID', isEqualTo: itemID)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Remove from local lists
      _itemReviews.removeWhere((r) => r.itemID == itemID);
      _allReviews.removeWhere((r) => r.itemID == itemID);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete item reviews: $e');
      return false;
    }
  }

  Future<bool> deleteReviewsByUser(int userID) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userID', isEqualTo: userID)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Remove from local lists
      _userReviews.removeWhere((r) => r.userID == userID);
      _allReviews.removeWhere((r) => r.userID == userID);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete user reviews: $e');
      return false;
    }
  }

  // ==================== STATISTICS ====================

  Future<double> getAverageRatingForItem(int itemID) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('itemID', isEqualTo: itemID)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      final reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();

      return reviews.averageRating;
    } catch (e) {
      debugPrint('Failed to get average rating: $e');
      return 0.0;
    }
  }

  Future<int> getReviewCountForItem(int itemID) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('itemID', isEqualTo: itemID)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Failed to get review count: $e');
      return 0;
    }
  }

  Future<Map<int, int>> getRatingDistributionForItem(int itemID) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('itemID', isEqualTo: itemID)
          .get();

      final reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();

      return reviews.ratingDistribution;
    } catch (e) {
      debugPrint('Failed to get rating distribution: $e');
      return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    }
  }

  // ==================== FILTERS ====================

  List<Review> getPositiveReviews(List<Review> reviews) {
    return reviews.where((r) => r.isPositive).toList();
  }

  List<Review> getNegativeReviews(List<Review> reviews) {
    return reviews.where((r) => r.isNegative).toList();
  }

  List<Review> getRecentReviews(List<Review> reviews) {
    return reviews.where((r) => r.isRecent).toList();
  }

  List<Review> filterByRating(List<Review> reviews, double minRating) {
    return reviews.where((r) => r.rating >= minRating).toList();
  }

  // ==================== VALIDATION ====================

  Future<bool> canUserReviewItem(int userID, int itemID) async {
    try {
      final existingReview = await _checkExistingReview(userID, itemID);
      return existingReview == null;
    } catch (e) {
      debugPrint('Failed to check review eligibility: $e');
      return false;
    }
  }

  Future<Review?> getUserReviewForItem(int userID, int itemID) async {
    return await _checkExistingReview(userID, itemID);
  }

  // ==================== STREAM SUPPORT ====================

  Stream<List<Review>> streamReviewsForItem(int itemID) {
    return _firestore
        .collection('reviews')
        .where('itemID', isEqualTo: itemID)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Review>> streamReviewsByUser(int userID) {
    return _firestore
        .collection('reviews')
        .where('userID', isEqualTo: userID)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();
    });
  }

  void listenToItemReviews(int itemID) {
    streamReviewsForItem(itemID).listen(
      (reviews) {
        _itemReviews = reviews;
        notifyListeners();
      },
      onError: (error) {
        _setError('Stream error: $error');
      },
    );
  }

  // ==================== HELPER METHODS ====================

  Review? getReviewById(String reviewId) {
    try {
      return _allReviews.firstWhere((review) => review.id == reviewId);
    } catch (e) {
      return null;
    }
  }

  List<Review> getItemReviewsSorted({bool newestFirst = true}) {
    final sorted = List<Review>.from(_itemReviews);
    if (newestFirst) {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    } else {
      sorted.sort((a, b) => a.date.compareTo(b.date));
    }
    return sorted;
  }

  List<Review> getItemReviewsByRating({bool highestFirst = true}) {
    final sorted = List<Review>.from(_itemReviews);
    if (highestFirst) {
      sorted.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      sorted.sort((a, b) => a.rating.compareTo(b.rating));
    }
    return sorted;
  }

  // ==================== PRIVATE HELPERS ====================

  void _setState(ReviewLoadingState newState) {
    _state = newState;
    if (newState != ReviewLoadingState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = ReviewLoadingState.error;
    _errorMessage = error;
    notifyListeners();
    debugPrint('ReviewViewModel Error: $error');
  }

  Future<Review?> _checkExistingReview(int userID, int itemID) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('userID', isEqualTo: userID)
          .where('itemID', isEqualTo: itemID)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data();
      data['id'] = snapshot.docs.first.id;
      return Review.fromJson(data);
    } catch (e) {
      debugPrint('Error checking existing review: $e');
      return null;
    }
  }

  void _updateReviewInLists(String reviewId, Review updatedReview) {
    // Update in all reviews
    final allIndex = _allReviews.indexWhere((r) => r.id == reviewId);
    if (allIndex != -1) _allReviews[allIndex] = updatedReview;

    // Update in item reviews
    final itemIndex = _itemReviews.indexWhere((r) => r.id == reviewId);
    if (itemIndex != -1) _itemReviews[itemIndex] = updatedReview;

    // Update in user reviews
    final userIndex = _userReviews.indexWhere((r) => r.id == reviewId);
    if (userIndex != -1) _userReviews[userIndex] = updatedReview;
  }

  void _removeReviewFromLists(String reviewId) {
    _allReviews.removeWhere((r) => r.id == reviewId);
    _itemReviews.removeWhere((r) => r.id == reviewId);
    _userReviews.removeWhere((r) => r.id == reviewId);
  }

  // ==================== BULK OPERATIONS ====================

  Future<bool> createMultipleReviews(List<Review> reviews) async {
    try {
      final batch = _firestore.batch();

      for (var review in reviews) {
        final docRef = _firestore.collection('reviews').doc();
        batch.set(docRef, review.toJson());
      }

      await batch.commit();
      return true;
    } catch (e) {
      _setError('Failed to create multiple reviews: $e');
      return false;
    }
  }

  // ==================== ANALYTICS ====================

  Future<Map<String, dynamic>> getItemReviewAnalytics(int itemID) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('itemID', isEqualTo: itemID)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'positivePercentage': 0.0,
          'recentReviews': 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      final reviews = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Review.fromJson(data);
      }).toList();

      return {
        'totalReviews': reviews.length,
        'averageRating': reviews.averageRating,
        'positivePercentage': reviews.positivePercentage,
        'recentReviews': reviews.recentReviews.length,
        'ratingDistribution': reviews.ratingDistribution,
        'positiveCount': reviews.positiveCount,
        'negativeCount': reviews.negativeCount,
        'neutralCount': reviews.neutralCount,
      };
    } catch (e) {
      debugPrint('Failed to get review analytics: $e');
      return {};
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}