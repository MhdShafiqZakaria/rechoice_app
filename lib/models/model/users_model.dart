import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final int userID;
  final String uid;
  final String name;
  final String email;
  final String profilePic;
  final String bio;
  final double reputationScore;

  // Admin management fields
  final UserStatus status;
  final DateTime joinDate;
  final DateTime lastLogin;
  final UserRole role;

  // Additional tracking
  final int totalListings;
  final int totalPurchases;
  final int totalSales;

  // Contact info (for cart/checkout)
  final String? phoneNumber;
  final String? address;

  Users({
    required this.uid,
    required this.userID,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.bio,
    required this.reputationScore,
    this.status = UserStatus.active,
    required this.joinDate,
    required this.lastLogin,
    this.role = UserRole.buyer,
    this.totalListings = 0,
    this.totalPurchases = 0,
    this.totalSales = 0,
    this.phoneNumber,
    this.address,
  });

  //Factory Method to create model instance from Json map (fromFirestore)

  factory Users.fromJson(Map<String, dynamic> json) {
    final joinTs = json['joinDate'] ?? json['createdAt'];
    final lastLoginTs = json['lastLogin'] ?? json['createdAt'];

    final uid = json['uid'] as String? ?? json['id'] as String? ?? '';

    if (uid.isEmpty) {
      print('WARNING: Creating Users instance with empty uid from data: $json');
    }

    return Users(
      uid: uid,
      userID: (json['userID'] as num?)?.toInt() ?? 0,
      name:
          json['name'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] as String? ?? '',
      profilePic: json['profilePic'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      reputationScore:
          (json['reputationScore'] as num?)?.toDouble() ?? 0.0, // FIX HERE
      status: UserStatus.values.byName(json['status'] ?? 'active'),
      joinDate: joinTs is Timestamp ? joinTs.toDate() : DateTime.now(),
      lastLogin: lastLoginTs is Timestamp
          ? lastLoginTs.toDate()
          : DateTime.now(),
      role: UserRole.values.byName(json['role'] ?? 'buyer'),
      totalListings: json['totalListings'] ?? 0,
      totalPurchases: json['totalPurchases'] ?? 0,
      totalSales: json['totalSales'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      address: json['address'],
    );
  }

  //Factory Method to convert model to Json structure for data storage in firebase (toFirestore)

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'userID': userID,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'bio': bio,
      'reputationScore': reputationScore,
      'status': status.toString().split('.').last,
      'joinDate': Timestamp.fromDate(joinDate),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'role': role.toString().split('.').last,
      'totalListings': totalListings,
      'totalPurchases': totalPurchases,
      'totalSales': totalSales,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }

  // Helper methods for admin
  bool get isActive => status == UserStatus.active;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isDeleted => status == UserStatus.deleted;
  bool get isAdmin => role == UserRole.admin;
  bool get isSeller => role == UserRole.seller;
  bool get isBuyer => role == UserRole.buyer;

  // Check if user has contact info
  bool get hasContactInfo => phoneNumber != null && address != null;

  // Check if user is new (joined within last 30 days)
  bool get isNewUser {
    final now = DateTime.now();
    final difference = now.difference(joinDate);
    return difference.inDays <= 30;
  }

  // Check if user was recently active (last login within 7 days)
  bool get isRecentlyActive {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);
    return difference.inDays <= 7;
  }

  // Create a copy with updated fields (useful for state management)
  Users copyWith({
    int? userID,
    String? name,
    String? email,
    String? profilePic,
    String? bio,
    double? reputationScore,
    UserStatus? status,
    DateTime? joinDate,
    DateTime? lastLogin,
    UserRole? role,
    int? totalListings,
    int? totalPurchases,
    int? totalSales,
    String? phoneNumber,
    String? address,
  }) {
    return Users(
      uid: uid,
      userID: userID ?? this.userID,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      reputationScore: reputationScore ?? this.reputationScore,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      lastLogin: lastLogin ?? this.lastLogin,
      role: role ?? this.role,
      totalListings: totalListings ?? this.totalListings,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalSales: totalSales ?? this.totalSales,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
    );
  }

  // Add helper methods for safe enum parsing
  static UserStatus _parseUserStatus(dynamic status) {
    if (status == null) return UserStatus.active;
    try {
      return UserStatus.values.byName(status.toString());
    } catch (e) {
      print('Invalid UserStatus: $status, defaulting to active');
      return UserStatus.active;
    }
  }

  static UserRole _parseUserRole(dynamic role) {
    if (role == null) return UserRole.buyer;
    try {
      return UserRole.values.byName(role.toString());
    } catch (e) {
      print('Invalid UserRole: $role, defaulting to buyer');
      return UserRole.buyer;
    }
  }
}

enum UserRole { buyer, seller, admin }

enum UserStatus { active, suspended, deleted }

// Extension for list operations (useful for admin screens)
extension UserListExtension on List<Users> {
  List<Users> get activeUsers => where((u) => u.isActive).toList();
  List<Users> get suspendedUsers => where((u) => u.isSuspended).toList();
  List<Users> get deletedUsers => where((u) => u.isDeleted).toList();
  List<Users> get sellers => where((u) => u.isSeller).toList();
  List<Users> get buyers => where((u) => u.isBuyer).toList();
  List<Users> get admins => where((u) => u.isAdmin).toList();

  int get totalActive => activeUsers.length;
  int get totalSuspended => suspendedUsers.length;
  int get totalSellers => sellers.length;
  int get totalBuyers => buyers.length;

  List<Users> get newUsers => where((u) => u.isNewUser).toList();
  List<Users> get recentlyActive => where((u) => u.isRecentlyActive).toList();

  List<Users> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return where((u) => u.name.toLowerCase().contains(lowerQuery)).toList();
  }

  List<Users> searchByEmail(String query) {
    final lowerQuery = query.toLowerCase();
    return where((u) => u.email.toLowerCase().contains(lowerQuery)).toList();
  }

  List<Users> get sortedByNewest {
    final sorted = List<Users>.from(this);
    sorted.sort((a, b) => b.joinDate.compareTo(a.joinDate));
    return sorted;
  }

  List<Users> get sortedByReputation {
    final sorted = List<Users>.from(this);
    sorted.sort((a, b) => b.reputationScore.compareTo(a.reputationScore));
    return sorted;
  }
}
