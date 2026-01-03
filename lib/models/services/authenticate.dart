import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirestoreService _firebaseFirestore = FirestoreService();

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      return await _firebaseFirestore.isAdmin(user.uid);
    } catch (e) {
      print('ERROR: Error checking admin status: $e');
      return false;
    }
  }

  // Check if current user has specific role
  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firebaseFirestore.getUser(user.uid);

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('ERROR: Error getting user role: $e');
      return null;
    }
  }

  // Check user status (active, suspended, deleted)
  Future<String?> getUserStatus() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firebaseFirestore.getUser(user.uid);

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['status'] as String?;
      }
      return null;
    } catch (e) {
      print('ERROR: Error getting user status: $e');
      return null;
    }
  }

  // Verify admin access (throws exception if not admin)
  Future<void> verifyAdminAccess() async {
    if (!await isAdmin()) {
      throw FirebaseAuthException(
        code: 'access-denied',
        message: 'Admin access required',
      );
    }
  }

  // Check if user can access the app (not suspended or deleted)
  Future<bool> canAccessApp() async {
    final status = await getUserStatus();
    return status == 'active' || status == null;
  }

  //email sign in/login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    print('DEBUG: Starting login for $email');

    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('DEBUG: Firebase Auth successful for ${userCredential.user?.uid}');

    // Check user status in Firestore
    if (userCredential.user != null) {
      try {
        print('DEBUG: Checking user status in Firestore');
        final userDoc = await _firebaseFirestore.getUser(
          userCredential.user!.uid,
        );
        final userData = userDoc.data() as Map<String, dynamic>?;

        print('DEBUG: User data retrieved: $userData');

        if (userData != null) {
          final status = userData['status'] as String?;
          print('DEBUG: User status: $status');

          // Check if user is suspended
          if (status == 'suspended') {
            print('DEBUG: User is suspended, signing out immediately');
            await firebaseAuth.signOut();
            print('DEBUG: Signed out, now throwing exception');
            throw FirebaseAuthException(
              code: 'user-suspended',
              message:
                  '⛔ Account Suspended - Your account has been suspended by admin. Please contact support to restore access.',
            );
          }

          // Check if user is deleted
          if (status == 'deleted') {
            print('DEBUG: User is deleted, signing out immediately');
            await firebaseAuth.signOut();
            print('DEBUG: Signed out, now throwing exception');
            throw FirebaseAuthException(
              code: 'user-deleted',
              message:
                  '🗑️ Account Deleted - This account has been permanently deleted.',
            );
          }

          // If status is 'active' or any other value, allow login
          print('DEBUG: User status is $status, allowing login');
        } else {
          // If userData is null, allow login (new user or document issue)
          print('DEBUG: User data is null, allowing login');
        }
      } catch (e) {
        print('DEBUG: Exception in status check: $e, Type: ${e.runtimeType}');
        // If it's our custom error, rethrow it
        if (e is FirebaseAuthException) {
          print('DEBUG: Rethrowing FirebaseAuthException');
          rethrow;
        }
        // For other errors, log but allow login
        print('ERROR: Error checking user status, but allowing login: $e');
      }
    }

    print('DEBUG: Login successful, returning credential');
    return userCredential;
  }

  //

  //email sign up/register
  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    // required String phoneNumber,
  }) async {
    //create user with email and password
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    //Create firestore user document
    await _firebaseFirestore.createUser(
      uid: userCredential.user!.uid,
      name: name,
      email: email,
    );
    return userCredential;
  }

  //user logout
  Future<void> logout() async {
    await firebaseAuth.signOut();
    // await googleSignIn.signOut();
  }

  //user reset password
  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
    }
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    if (currentUser != null) return;

    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);

    // Soft delete in Firestore first
    await _firebaseFirestore.softDeleteUser(currentUser!.uid);

    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  // Permanently delete account (admin function)
  Future<void> permanentlyDeleteAccount({required String uid}) async {
    await _firebaseFirestore.permanentlyDeleteUser(uid);
  }

  //user change password
  Future<void> resetPwFromCurrPw({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    if (currentUser != null) return;
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }

  // Admin Functions - wrapped for convenience

  // Update user role (admin only)
  Future<void> updateUserRole(String uid, String role) async {
    await verifyAdminAccess();
    await _firebaseFirestore.updateUserRole(uid, role);
  }

  // Update user status (admin only)
  Future<void> updateUserStatus(String uid, String status) async {
    await verifyAdminAccess();
    await _firebaseFirestore.updateUserStatus(uid, status);
  }

  // Suspend user (admin only)
  Future<void> suspendUser(String uid) async {
    await verifyAdminAccess();
    await _firebaseFirestore.updateUserStatus(uid, 'suspended');
  }

  // Activate user (admin only)
  Future<void> activateUser(String uid) async {
    await verifyAdminAccess();
    await _firebaseFirestore.updateUserStatus(uid, 'active');
  }

  // Batch update user statuses (admin only)
  Future<void> batchUpdateUserStatus(List<String> uids, String status) async {
    await verifyAdminAccess();
    await _firebaseFirestore.batchUpdateUserStatus(uids, status);
  }

  // Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers({String? statusFilter}) async {
    await verifyAdminAccess();

    final snapshot = await _firebaseFirestore.getAllUsers(
      statusFilter: statusFilter,
    );
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  // Search users (admin only)
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    await verifyAdminAccess();

    final docs = await _firebaseFirestore.searchUsers(query);
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = doc.id;
      return data;
    }).toList();
  }

  // Get user statistics (admin only)
  Future<Map<String, dynamic>> getUserStatistics() async {
    await verifyAdminAccess();

    final statusCounts = await _firebaseFirestore.getUserCountsByStatus();
    final roleCounts = await _firebaseFirestore.getUserCountsByRole();

    return {
      'statusCounts': statusCounts,
      'roleCounts': roleCounts,
      'totalUsers': statusCounts.values.fold<int>(
        0,
        (sum, count) => sum + count,
      ),
    };
  }

  //google sign in
  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     //trigger google sign in flow

  //     final GoogleSignInAccount? gUser = await googleSignIn.signIn();
  //     if (gUser == null) return null; // User cancelled

  //     //await auth details from request
  //     final GoogleSignInAuthentication gAuth = await gUser.authentication;

  //     // Ensure tokens are available (additional safety)
  //     if (gAuth.idToken == null || gAuth.accessToken == null) {
  //       throw FirebaseAuthException(
  //         code: 'missing-tokens',
  //         message: 'Authentication tokens are missing. Please try again.',
  //       );
  //     }

  //     // Create a new credential for user (fixes error 3 by using correct getters)
  //     final credential = GoogleAuthProvider.credential(
  //       idToken: gAuth.idToken,
  //       accessToken: gAuth.accessToken, // Corrected: Use gAuth.accessToken
  //     );

  //     // Sign in with Firebase Auth to get UserCredential (fixes errors 4 & 5)
  //     final userCredential = await FirebaseAuth.instance.signInWithCredential(
  //       credential,
  //     );
  //     final firebaseUser = userCredential.user;

  //     // Now accessible from UserCredential

  //     // Create Firestore user if new (optional, with error handling)
  //     if (firebaseUser != null) {
  //       try {
  //         final userDoc = await _firebaseFirestore.getUser(firebaseUser.uid);
  //         if (!userDoc.exists) {
  //           await _firebaseFirestore.createUser(
  //             uid: firebaseUser.uid,
  //             name: firebaseUser.displayName ?? '',
  //             email: firebaseUser.email ?? '',
  //           );
  //         }
  //       } catch (e) {
  //         print('Firestore operation failed: $e');
  //         // Optionally handle or rethrow
  //       }
  //     }

  //     return userCredential; // Fixed: Return UserCredential, not OAuthCredential
  //   } catch (e) {
  //     throw FirebaseAuthException(
  //       code: 'google-signin-failed',
  //       message: e.toString(),
  //     );
  //   }
  // }
}
