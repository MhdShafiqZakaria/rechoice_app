// models/user.dart

enum UserRole {
  buyer,
  seller,
  admin,
}

enum UserStatus {
  active,
  suspended,
  deleted,
}

class User {
  final int userID;
  final String name;
  final String email;
  final String password;
  final String profilePic;
  final String bio;
  final double reputationScore;
  
  // NEW: Admin management fields
  final UserStatus status;
  final DateTime joinDate;
  final DateTime lastLogin;
  final UserRole role;
  
  // Optional: Additional tracking
  final int totalListings;
  final int totalPurchases;

  User({
    required this.userID,
    required this.name,
    required this.email,
    required this.password,
    required this.profilePic,
    required this.bio,
    required this.reputationScore,
    this.status = UserStatus.active,
    required this.joinDate,
    required this.lastLogin,
    this.role = UserRole.buyer,
    this.totalListings = 0,
    this.totalPurchases = 0,
  });

  // Firebase ready - fromJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      profilePic: json['profilePic'],
      bio: json['bio'],
      reputationScore: json['reputationScore'].toDouble(),
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == 'UserStatus.${json['status']}',
        orElse: () => UserStatus.active,
      ),
      joinDate: DateTime.parse(json['joinDate']),
      lastLogin: DateTime.parse(json['lastLogin']),
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.buyer,
      ),
      totalListings: json['totalListings'] ?? 0,
      totalPurchases: json['totalPurchases'] ?? 0,
    );
  }

  // Firebase ready - toJson
  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'password': password,
      'profilePic': profilePic,
      'bio': bio,
      'reputationScore': reputationScore,
      'status': status.toString().split('.').last,
      'joinDate': joinDate.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'role': role.toString().split('.').last,
      'totalListings': totalListings,
      'totalPurchases': totalPurchases,
    };
  }

  // Helper methods for admin
  bool get isActive => status == UserStatus.active;
  bool get isSuspended => status == UserStatus.suspended;
  bool get isAdmin => role == UserRole.admin;
  bool get isSeller => role == UserRole.seller;
  bool get isBuyer => role == UserRole.buyer;

  // Get status color for UI
  String get statusText {
    switch (status) {
      case UserStatus.active:
        return 'active';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.deleted:
        return 'deleted';
    }
  }

  // Get formatted join date
  String get formattedJoinDate {
    return '${joinDate.year}-${joinDate.month.toString().padLeft(2, '0')}-${joinDate.day.toString().padLeft(2, '0')}';
  }

  // Get formatted last login
  String get formattedLastLogin {
    return '${lastLogin.year}-${lastLogin.month.toString().padLeft(2, '0')}-${lastLogin.day.toString().padLeft(2, '0')}';
  }

  // Create a copy with updated fields (useful for state management)
  User copyWith({
    int? userID,
    String? name,
    String? email,
    String? password,
    String? profilePic,
    String? bio,
    double? reputationScore,
    UserStatus? status,
    DateTime? joinDate,
    DateTime? lastLogin,
    UserRole? role,
    int? totalListings,
    int? totalPurchases,
  }) {
    return User(
      userID: userID ?? this.userID,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      reputationScore: reputationScore ?? this.reputationScore,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      lastLogin: lastLogin ?? this.lastLogin,
      role: role ?? this.role,
      totalListings: totalListings ?? this.totalListings,
      totalPurchases: totalPurchases ?? this.totalPurchases,
    );
  }
}

// Extension for list operations (useful for admin screens)
extension UserListExtension on List<User> {
  List<User> get activeUsers => where((u) => u.isActive).toList();
  List<User> get suspendedUsers => where((u) => u.isSuspended).toList();
  List<User> get sellers => where((u) => u.isSeller || u.role == UserRole.seller).toList();
  List<User> get buyers => where((u) => u.isBuyer).toList();
  
  int get totalActive => activeUsers.length;
  int get totalSuspended => suspendedUsers.length;
}