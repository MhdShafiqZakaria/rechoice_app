import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get firestoreInstance => _db;

  // ==================== USERS CRUD OPERATIONS ====================

  //Create User function
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    //Get the next userID (auto-increment)
    final counterRef = _db.collection('metadata').doc('userCounter');
    int nextUserID = 1;

    try {
      final counterDoc = await counterRef.get();
      if (counterDoc.exists) {
        nextUserID = (counterDoc.data()?['count'] ?? 0) + 1;
      }
      //increment counter
      await counterRef.set({'count': nextUserID});
    } catch (e) {
      print('Error getting userID: $e');
    }

    //create user document
    await _db.collection('users').doc(uid).set({
      'userID': nextUserID,
      'name': name,
      'email': email,
      'profilePic': '',
      'bio': '',
      'reputationScore': 0.0,
      'status': 'active',
      'joinDate': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'role': 'buyer',
      'totalListings': 0,
      'totalPurchases': 0,
      'totalSales': 0,
      'phoneNumber': null,
      'address': null,
    });

    print('✅ User document created for $email with userID: $nextUserID');
  }

  //
  //Read User Document
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  //Update User Document
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  //Delete User Document
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  //Check if User is admin
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;

    final data = doc.data();
    return data?['role'] == 'admin';
  }

  // Update last login
  Future<void> updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // ==================== ADMIN OPERATIONS ====================

  // Update user status (active, suspended, deleted)
  Future<void> updateUserStatus(String uid, String status) async {
    if (!['active', 'suspended', 'deleted'].contains(status)) {
      throw ArgumentError('Invalid status: $status');
    }

    await _db.collection('users').doc(uid).update({'status': status});
  }

  // Update user role (buyer, seller, admin)
  Future<void> updateUserRole(String uid, String role) async {
    if (!['buyer', 'seller', 'admin'].contains(role)) {
      throw ArgumentError('Invalid role: $role');
    }

    await _db.collection('users').doc(uid).update({'role': role});
  }

  // Get all users with optional status filter
  Future<QuerySnapshot> getAllUsers({String? statusFilter}) async {
    Query query = _db.collection('users');

    if (statusFilter != null && statusFilter != 'All Status') {
      query = query.where('status', isEqualTo: statusFilter.toLowerCase());
    }

    return await query.get();
  }

  // Get users by role
  Future<QuerySnapshot> getUsersByRole(String role) async {
    return await _db
        .collection('users')
        .where('role', isEqualTo: role.toLowerCase())
        .get();
  }

  // Get users by status
  Future<QuerySnapshot> getUsersByStatus(String status) async {
    return await _db
        .collection('users')
        .where('status', isEqualTo: status.toLowerCase())
        .get();
  }

  // Batch update user statuses
  Future<void> batchUpdateUserStatus(List<String> uids, String status) async {
    if (!['active', 'suspended', 'deleted'].contains(status)) {
      throw ArgumentError('Invalid status: $status');
    }

    final batch = _db.batch();

    for (final uid in uids) {
      final docRef = _db.collection('users').doc(uid);
      batch.update(docRef, {'status': status});
    }

    await batch.commit();
  }

  // Update user statistics (for tracking)
  Future<void> updateUserStats(
    String uid, {
    int? totalListings,
    int? totalPurchases,
    int? totalSales,
  }) async {
    final updateData = <String, dynamic>{};

    if (totalListings != null) updateData['totalListings'] = totalListings;
    if (totalPurchases != null) updateData['totalPurchases'] = totalPurchases;
    if (totalSales != null) updateData['totalSales'] = totalSales;

    if (updateData.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updateData);
    }
  }

  // Increment user statistics
  Future<void> incrementUserStats(
    String uid, {
    int listingsDelta = 0,
    int purchasesDelta = 0,
    int salesDelta = 0,
  }) async {
    final updateData = <String, dynamic>{};

    if (listingsDelta != 0) {
      updateData['totalListings'] = FieldValue.increment(listingsDelta);
    }
    if (purchasesDelta != 0) {
      updateData['totalPurchases'] = FieldValue.increment(purchasesDelta);
    }
    if (salesDelta != 0) {
      updateData['totalSales'] = FieldValue.increment(salesDelta);
    }

    if (updateData.isNotEmpty) {
      await _db.collection('users').doc(uid).update(updateData);
    }
  }

  // Update reputation score
  Future<void> updateReputationScore(String uid, double score) async {
    await _db.collection('users').doc(uid).update({'reputationScore': score});
  }

  // Search users by name or email
  Future<List<DocumentSnapshot>> searchUsers(String query) async {
    final lowerQuery = query.toLowerCase();

    final snapshot = await _db.collection('users').get();

    return snapshot.docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] as String? ?? '').toLowerCase();
      final email = (data['email'] as String? ?? '').toLowerCase();

      return name.contains(lowerQuery) || email.contains(lowerQuery);
    }).toList();
  }

  // Get user count by status
  Future<Map<String, int>> getUserCountsByStatus() async {
    final snapshot = await _db.collection('users').get();

    final counts = <String, int>{'active': 0, 'suspended': 0, 'deleted': 0};

    for (final doc in snapshot.docs) {
      final status = doc.data()['status'] as String? ?? 'active';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  // Get user count by role
  Future<Map<String, int>> getUserCountsByRole() async {
    final snapshot = await _db.collection('users').get();

    final counts = <String, int>{'buyer': 0, 'seller': 0, 'admin': 0};

    for (final doc in snapshot.docs) {
      final role = doc.data()['role'] as String? ?? 'buyer';
      counts[role] = (counts[role] ?? 0) + 1;
    }

    return counts;
  }

  // Soft delete (set status to deleted instead of removing document)
  Future<void> softDeleteUser(String uid) async {
    await updateUserStatus(uid, 'deleted');
  }

  // Permanently delete user and all related data
  Future<void> permanentlyDeleteUser(String uid) async {
    final batch = _db.batch();

    // Delete user document
    batch.delete(_db.collection('users').doc(uid));

    // You can add more deletions here for related data
    // e.g., user's listings, cart items, orders, etc.

    await batch.commit();
  }
}
