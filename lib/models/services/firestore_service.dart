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
}
