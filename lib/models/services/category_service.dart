import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/model/category_model.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';

class CategoryService {
  final FirestoreService _firestoreService;

  CategoryService(this._firestoreService);

  CollectionReference get _categoriesCollection =>
      _firestoreService.firestoreInstance.collection('categories');

  CollectionReference get _metadataCollection =>
      _firestoreService.firestoreInstance.collection('metadata');

  // ==================== CREATE ====================

  Future<String> createCategory({
    required String name,
    required String iconName,
  }) async {
    try {
      // Check if already exists first
      if (await categoryExists(name)) {
        throw Exception('Category "$name" already exists');
      }

      return await _firestoreService.firestoreInstance.runTransaction<String>((
        transaction,
      ) async {
        final counterRef = _metadataCollection.doc('categoryCounter');
        final counterDoc = await transaction.get(counterRef);

        int nextCategoryID = 1;
        if (counterDoc.exists) {
          final data = counterDoc.data() as Map<String, dynamic>?;
          nextCategoryID = (data?['count'] ?? 0) + 1;
        }

        // Atomically update counter
        transaction.set(counterRef, {'count': nextCategoryID});

        // Create category document
        final newDocRef = _categoriesCollection.doc();
        transaction.set(newDocRef, {
          'categoryID': nextCategoryID,
          'name': name,
          'iconName': iconName,
        });

        return newDocRef.id;
      });
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // ==================== READ ====================

  Future<ItemCategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesCollection.doc(categoryId).get();
      if (!doc.exists) return null;
      return ItemCategoryModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  Future<ItemCategoryModel?> getCategoryByNumericId(int categoryId) async {
    try {
      final snapshot = await _categoriesCollection
          .where('categoryID', isEqualTo: categoryId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return ItemCategoryModel.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  Future<List<ItemCategoryModel>> getAllCategories() async {
    try {
      final snapshot = await _categoriesCollection.orderBy('name').get();

      return snapshot.docs
          .map(
            (doc) =>
                ItemCategoryModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Stream<List<ItemCategoryModel>> streamCategories() {
    return _categoriesCollection
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ItemCategoryModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  // ==================== UPDATE ====================

  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _categoriesCollection.doc(categoryId).update(updates);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // ==================== DELETE ====================

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // ==================== UTILITY ====================

  Future<bool> categoryExists(String name) async {
    try {
      final snapshot = await _categoriesCollection
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check category existence: $e');
    }
  }

  Future<int> getCategoryCount() async {
    try {
      final snapshot = await _categoriesCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Failed to get category count: $e');
    }
  }

  // ==================== SEED DATA ====================

  Future<void> seedDefaultCategories() async {
    try {
      final count = await getCategoryCount();
      if (count > 0) {
        return;
      }

      // Explicitly typed to fix the '[]' operator error on Object
      final defaultCategories = <Map<String, String>>[
        {'name': 'Electronics', 'iconName': 'electronics'},
        {'name': 'Fashion', 'iconName': 'fashions'},
        {'name': 'Personal Care', 'iconName': 'brush'},
        {'name': 'Book/Study', 'iconName': 'books'},
        {'name': 'Home/Living', 'iconName': 'files'},
      ];

      for (final category in defaultCategories) {
        final name = category['name'];
        final iconName = category['iconName'];
        if (name != null && iconName != null) {
          await createCategory(name: name, iconName: iconName);
          await Future.delayed(Duration(milliseconds: 100)); // Add small delay
        }
      }

    } catch (e) {
      throw Exception('Failed to seed categories: $e');
    }
  }
}
