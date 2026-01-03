import 'package:flutter/material.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';

class UsersViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;

  UsersViewModel({required FirestoreService firestoreService})
    : _firestoreService = firestoreService;

  List<Users> _users = [];
  List<Users> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Users? getUserByUid(String uid) {
    try {
      return _users.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
  }

  // NEW METHOD: Fetch single user by UID
  Future<Users?> fetchUserByUid(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Fetching user with uid: $uid'); // Debug log
      final doc = await _firestoreService.getUser(uid);

      if (!doc.exists) {
        print('User document does not exist for uid: $uid'); // Debug log
        _errorMessage = 'User not found';
        return null;
      }
      print('User document found: ${doc.data()}'); // Debug log
      final data = Map<String, dynamic>.from(
        doc.data() as Map<String, dynamic>,
      );
      data['uid'] = uid;
      final user = Users.fromJson(data);
      print('User parsed: ${user.name}, uid: ${user.uid}'); // Debug log
      // Add to cache if not already there
      final existingIndex = _users.indexWhere((u) => u.uid == uid);
      if (existingIndex != -1) {
        _users[existingIndex] = user;
      } else {
        _users.add(user);
      }

      return user;
    } catch (e) {
      print('Error fetching user: $e'); // Debug log
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all users from Firestore
  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestoreService.firestoreInstance
          .collection('users')
          .get();

      if (snapshot.docs.isEmpty) {
        _users = [];
        return;
      }

      _users = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['uid'] = doc.id;
        // Add document ID as uid
        return Users.fromJson(data);
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get filtered users based on search, status, and role
  List<Users> getFilteredUsers({
    String? searchQuery,
    String? status,
    String? role,
  }) {
    return _users.where((user) {
      // Search filter
      final matchesSearch =
          searchQuery == null ||
          searchQuery.isEmpty ||
          user.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase());

      // Status filter
      final userStatusString = user.status
          .toString()
          .split('.')
          .last
          .toLowerCase();
      final matchesStatus =
          status == null || userStatusString == status.toLowerCase();

      // Role filter
      final userRoleString = user.role.toString().split('.').last.toLowerCase();
      final matchesRole = role == null || userRoleString == role.toLowerCase();

      return matchesSearch && matchesStatus && matchesRole;
    }).toList();
  }

  // Get status counts
  Map<String, int> getStatusCounts() {
    return {
      'active': _users.where((u) => u.isActive).length,
      'suspended': _users.where((u) => u.isSuspended).length,
      'inactive': _users
          .where((u) => !u.isActive && !u.isSuspended && !u.isDeleted)
          .length,
    };
  }

  // Get role counts
  Map<String, int> getRoleCounts() {
    return {
      'buyer': _users.where((u) => u.isBuyer).length,
      'seller': _users.where((u) => u.isSeller).length,
      'admin': _users.where((u) => u.isAdmin).length,
    };
  }

  // Search users by name or email
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await loadUsers();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      //fetch all users
      final snapshot = await _firestoreService.firestoreInstance
          .collection('users')
          .get();

      final allUsers = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['uid'] = doc.id;
        return Users.fromJson(data);
      }).toList();

      final lowerQuery = query.toLowerCase();
      _users = allUsers.where((user) {
        return user.name.toLowerCase().contains(lowerQuery) ||
            user.email.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
    String uid, {
    String? name,
    String? bio,
    String? phoneNumber,
    String? address,
    String? profilePic,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (bio != null) updateData['bio'] = bio;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (profilePic != null) updateData['profilePic'] = profilePic;

      await _firestoreService.updateUser(uid, updateData);

      // Refresh user in local list
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        final doc = await _firestoreService.getUser(uid);
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          data['uid'] = uid;
          _users[index] = Users.fromJson(data);
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user role (admin operation)
  Future<void> updateUserRole(String uid, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateUserRole(uid, role);

      // Update local list
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        final userRole = UserRole.values.byName(role);
        _users[index] = _users[index].copyWith(role: userRole);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update local user (for optimistic updates)
  void updateLocalUser(Users updatedUser) {
    final index = _users.indexWhere((u) => u.uid == updatedUser.uid);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  // Admin: Suspend user
  Future<void> suspendUser(String uid) async {
    await _updateUserStatus(uid, UserStatus.suspended);
  }

  // Admin: Activate user
  Future<void> activateUser(String uid) async {
    await _updateUserStatus(uid, UserStatus.active);
  }

  // Admin: Delete user
  Future<void> deleteUser(String uid) async {
    await _updateUserStatus(uid, UserStatus.deleted);
  }

  // Helper: Update user status in Firestore
  // Helper: Update user status in Firestore
  Future<void> _updateUserStatus(String uid, UserStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestoreService.updateUserStatus(
        uid,
        status.toString().split('.').last,
      );

      // Update local list
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(status: status);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtered lists (computed from current state)
  List<Users> get activeUsers => _users.where((u) => u.isActive).toList();
  List<Users> get suspendedUsers => _users.where((u) => u.isSuspended).toList();
  List<Users> get sellers => _users.where((u) => u.isSeller).toList();

  // Static helper methods
  static String getRoleText(UserRole role) {
    switch (role) {
      case UserRole.buyer:
        return 'Buyer';
      case UserRole.seller:
        return 'Seller';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static String getInitials(String? name) {
    if (name == null || name.trim().isEmpty)
      return '?'; // Fallback for null/empty names

    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final names = trimmed
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList(); // Filter out empty parts

    if (names.length >= 2) {
      // Take first char of first two parts, if available
      final first = names[0].isNotEmpty ? names[0][0] : '?';
      final second = names[1].isNotEmpty ? names[1][0] : '?';
      return '$first$second'.toUpperCase();
    } else if (names.isNotEmpty && names[0].isNotEmpty) {
      // Single name: Take first 1-2 chars safely
      final firstPart = names[0];
      if (firstPart.length >= 2) {
        return firstPart.substring(0, 2).toUpperCase();
      } else {
        return firstPart[0].toUpperCase(); // Just the first char if only 1 char
      }
    }

    return '?'; // Ultimate fallback
  }

  static String getUsername(String email) {
    return email.split('@')[0];
  }

  static String getFormattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String getMemberSince(DateTime joinDate) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return 'Joined ${months[joinDate.month - 1]} ${joinDate.year}';
  }
}
