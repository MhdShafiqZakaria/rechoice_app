// // services/admin_dummy_data.dart

// import 'package:test_project/models/user.dart';
// import 'package:test_project/models/item.dart';
// //import 'package:test_project/models/category.dart';
// import 'package:test_project/models/activity.dart';
// import 'package:test_project/models/analytics.dart';

// class AdminDummyDataService {
//   // ==================== USERS DATA ====================

//   static List<User> getAllUsers() {
//     final now = DateTime.now();

//     return [
//       User(
//         userID: 1,
//         name: 'John Smith',
//         email: 'john@example.com',
//         password: 'hashed_password',
//         profilePic: 'https://via.placeholder.com/150',
//         bio: 'Tech enthusiast',
//         reputationScore: 4.8,
//         status: UserStatus.active,
//         joinDate: DateTime(2024, 1, 15),
//         lastLogin: DateTime(2024, 3, 10),
//         role: UserRole.buyer,
//         totalListings: 0,
//         totalPurchases: 5,
//       ),
//       User(
//         userID: 2,
//         name: 'Sarah Johnson',
//         email: 'sarah@example.com',
//         password: 'hashed_password',
//         profilePic: 'https://via.placeholder.com/150',
//         bio: 'Selling preloved items',
//         reputationScore: 4.2,
//         status: UserStatus.active,
//         joinDate: DateTime(2024, 2, 20),
//         lastLogin: DateTime(2024, 3, 8),
//         role: UserRole.seller,
//         totalListings: 8,
//         totalPurchases: 2,
//       ),
//       User(
//         userID: 3,
//         name: 'Mike Chen',
//         email: 'mike@example.com',
//         password: 'hashed_password',
//         profilePic: 'https://via.placeholder.com/150',
//         bio: 'Gadget lover',
//         reputationScore: 4.9,
//         status: UserStatus.active,
//         joinDate: DateTime(2024, 1, 5),
//         lastLogin: DateTime(2024, 3, 11),
//         role: UserRole.buyer,
//         totalListings: 0,
//         totalPurchases: 12,
//       ),
//       User(
//         userID: 4,
//         name: 'Emma Wilson',
//         email: 'emma@example.com',
//         password: 'hashed_password',
//         profilePic: 'https://via.placeholder.com/150',
//         bio: 'Student seller',
//         reputationScore: 4.6,
//         status: UserStatus.active,
//         joinDate: DateTime(2024, 2, 28),
//         lastLogin: DateTime(2024, 3, 9),
//         role: UserRole.seller,
//         totalListings: 15,
//         totalPurchases: 3,
//       ),
//       User(
//         userID: 5,
//         name: 'Alex Taylor',
//         email: 'alex@example.com',
//         password: 'hashed_password',
//         profilePic: 'https://via.placeholder.com/150',
//         bio: 'Part-time reseller',
//         reputationScore: 4.7,
//         status: UserStatus.active,
//         joinDate: DateTime(2024, 1, 22),
//         lastLogin: DateTime(2024, 3, 10),
//         role: UserRole.seller,
//         totalListings: 22,
//         totalPurchases: 7,
//       ),
//       User(
//         userID: 6,
//         name: 'Lisa Anderson',
//         email: 'lisa@example.com',
//         password: 'hashed_password',
//         profilePic: 'https://via.placeholder.com/150',
//         bio: 'Bargain hunter',
//         reputationScore: 4.4,
//         status: UserStatus.active,
//         joinDate: DateTime(2024, 2, 10),
//         lastLogin: DateTime(2024, 3, 11),
//         role: UserRole.buyer,
//         totalListings: 0,
//         totalPurchases: 8,
//       ),
//     ];
//   }

//   // ==================== ACTIVITIES DATA ====================

//   static List<Activity> getRecentActivities() {
//     final now = DateTime.now();

//     return [
//       Activity(
//         activityID: 1,
//         type: ActivityType.userRegistration,
//         title: 'New user registration',
//         description: 'John Smith joined the platform',
//         timestamp: now.subtract(const Duration(minutes: 2)),
//         userID: 1,
//       ),
//       Activity(
//         activityID: 2,
//         type: ActivityType.listingApproved,
//         title: 'Listing approved',
//         description: 'iPhone 15 Pro listing was approved',
//         timestamp: now.subtract(const Duration(minutes: 5)),
//         userID: 5,
//         itemID: 1,
//       ),
//       Activity(
//         activityID: 3,
//         type: ActivityType.reportReceived,
//         title: 'Report received',
//         description: 'Inappropriate content reported',
//         timestamp: now.subtract(const Duration(minutes: 10)),
//         userID: 3,
//         itemID: 8,
//       ),
//       Activity(
//         activityID: 4,
//         type: ActivityType.purchaseCompleted,
//         title: 'Purchase completed',
//         description: 'Mike Chen purchased MacBook Air M2',
//         timestamp: now.subtract(const Duration(minutes: 15)),
//         userID: 3,
//         itemID: 2,
//       ),
//       Activity(
//         activityID: 5,
//         type: ActivityType.listingCreated,
//         title: 'New listing created',
//         description: 'Samsung Galaxy S24 listed for sale',
//         timestamp: now.subtract(const Duration(minutes: 25)),
//         userID: 4,
//         itemID: 3,
//       ),
//       Activity(
//         activityID: 6,
//         type: ActivityType.userSuspended,
//         title: 'User suspended',
//         description: 'Sarah Johnson was suspended for policy violation',
//         timestamp: now.subtract(const Duration(hours: 1)),
//         userID: 2,
//         targetUserID: 2,
//       ),
//       Activity(
//         activityID: 7,
//         type: ActivityType.listingRejected,
//         title: 'Listing rejected',
//         description: 'Counterfeit item listing was rejected',
//         timestamp: now.subtract(const Duration(hours: 2)),
//         userID: 2,
//         itemID: 10,
//       ),
//       Activity(
//         activityID: 8,
//         type: ActivityType.listingApproved,
//         title: 'Listing approved',
//         description: 'AirPods Pro listing was approved',
//         timestamp: now.subtract(const Duration(hours: 3)),
//         userID: 5,
//         itemID: 5,
//       ),
//     ];
//   }

//   // ==================== DASHBOARD METRICS ====================

//   static DashboardMetrics getDashboardMetrics() {
//     return DashboardMetrics(
//       totalUsers: 1247,
//       activeUsers: 892,
//       totalListings: 3456,
//       pendingReports: 22,
//       usersGrowth: 12.5,
//       activeUsersGrowth: 8.2,
//       listingsGrowth: 15.3,
//       newReports: 5,
//     );
//   }

//   // ==================== REPORT ANALYTICS ====================

//   static ReportAnalytics getReportAnalytics() {
//     return ReportAnalytics(
//       totalReports: 89,
//       resolvedReports: 67,
//       pendingReports: 22,
//     );
//   }

//   // ==================== ITEMS FOR MODERATION ====================

//   static List<Item> getItemsForModeration() {
//     final categories = _getCategories();
//     final now = DateTime.now();

//     return [
//       Item(
//         itemID: 101,
//         title: 'iPhone 15 Pro Max',
//         category: categories[0], // Phones
//         brand: 'Apple',
//         condition: 'Like New',
//         price: 1299.00,
//         quantity: 1,
//         description: 'iPhone 15 Pro Max 256GB Natural Titanium, barely used',
//         status: 'available',
//         images: ['https://via.placeholder.com/300'],
//         moderationStatus: ModerationStatus.pending,
//         postedDate: now.subtract(const Duration(days: 1)),
//         sellerID: 5,
//       ),
//       Item(
//         itemID: 102,
//         title: 'MacBook Air M2',
//         category: categories[2], // Laptops
//         brand: 'Apple',
//         condition: 'Excellent',
//         price: 4999.00,
//         quantity: 1,
//         description: 'MacBook Air M2 8GB RAM 256GB SSD, mint condition',
//         status: 'available',
//         images: ['https://via.placeholder.com/300'],
//         moderationStatus: ModerationStatus.approved,
//         postedDate: now.subtract(const Duration(days: 2)),
//         sellerID: 4,
//         moderatedDate: now.subtract(const Duration(days: 1)),
//         moderatedBy: 999, // Admin ID
//       ),
//       Item(
//         itemID: 103,
//         title: 'Samsung Galaxy S24',
//         category: categories[0], // Phones
//         brand: 'Samsung',
//         condition: 'Good',
//         price: 3299.00,
//         quantity: 1,
//         description: 'Samsung Galaxy S24 Ultra 512GB',
//         status: 'available',
//         images: ['https://via.placeholder.com/300'],
//         moderationStatus: ModerationStatus.flagged,
//         postedDate: now.subtract(const Duration(days: 3)),
//         sellerID: 2,
//         moderatedDate: now.subtract(const Duration(hours: 12)),
//         moderatedBy: 999,
//         rejectionReason: 'Suspicious pricing, needs verification',
//       ),
//       Item(
//         itemID: 104,
//         title: 'Sony WH-1000XM5',
//         category: categories[4], // Audio
//         brand: 'Sony',
//         condition: 'Like New',
//         price: 399.00,
//         quantity: 1,
//         description: 'Premium noise-cancelling headphones',
//         status: 'available',
//         images: ['https://via.placeholder.com/300'],
//         moderationStatus: ModerationStatus.pending,
//         postedDate: now.subtract(const Duration(hours: 5)),
//         sellerID: 5,
//       ),
//       Item(
//         itemID: 105,
//         title: 'iPad Pro 11',
//         category: categories[2], // Laptops
//         brand: 'Apple',
//         condition: 'Excellent',
//         price: 2999.00,
//         quantity: 1,
//         description: 'iPad Pro 11 inch M2 chip 128GB',
//         status: 'available',
//         images: ['https://via.placeholder.com/300'],
//         moderationStatus: ModerationStatus.approved,
//         postedDate: now.subtract(const Duration(days: 4)),
//         sellerID: 4,
//         moderatedDate: now.subtract(const Duration(days: 3)),
//         moderatedBy: 999,
//       ),
//       Item(
//         itemID: 106,
//         title: 'PS5 Console',
//         category: categories[1], // Consoles
//         brand: 'Sony',
//         condition: 'Good',
//         price: 549.00,
//         quantity: 1,
//         description: 'PlayStation 5 with controller',
//         status: 'available',
//         images: ['https://via.placeholder.com/300'],
//         moderationStatus: ModerationStatus.pending,
//         postedDate: now.subtract(const Duration(hours: 8)),
//         sellerID: 5,
//       ),
//       Item(
//         itemID: 107,
//         title: 'Canon EOS R6',
//         category: categories[3], // Cameras
//         brand: 'Canon',
//         condition: 'Excellent',
//         price: 1899.00,
//         quantity: 1,
//         description: 'Full-frame mirrorless camera with lens',
//         status: 'available',
//         images: ['https://via.placeholder.com/300'],
//         moderationStatus: ModerationStatus.rejected,
//         postedDate: now.subtract(const Duration(days: 5)),
//         sellerID: 2,
//         moderatedDate: now.subtract(const Duration(days: 4)),
//         moderatedBy: 999,
//         rejectionReason: 'Incomplete product information',
//       ),
//     ];
//   }

//   // Helper: Get categories
//   static List<Category> _getCategories() {
//     return [
//       Category(categoryID: 1, name: 'Phones', iconName: 'phone'),
//       Category(categoryID: 2, name: 'Consoles', iconName: 'gamepad'),
//       Category(categoryID: 3, name: 'Laptops', iconName: 'laptop'),
//       Category(categoryID: 4, name: 'Cameras', iconName: 'camera'),
//       Category(categoryID: 5, name: 'Audio', iconName: 'headphones'),
//     ];
//   }

//   // ==================== MONTHLY ANALYTICS (BONUS) ====================

//   static List<MonthlyAnalytics> getMonthlyAnalytics() {
//     return [
//       MonthlyAnalytics(
//         month: '2024-01',
//         newUsers: 120,
//         newListings: 350,
//         completedTransactions: 280,
//         newReports: 8,
//       ),
//       MonthlyAnalytics(
//         month: '2024-02',
//         newUsers: 145,
//         newListings: 420,
//         completedTransactions: 340,
//         newReports: 12,
//       ),
//       MonthlyAnalytics(
//         month: '2024-03',
//         newUsers: 180,
//         newListings: 510,
//         completedTransactions: 410,
//         newReports: 15,
//       ),
//     ];
//   }

//   // ==================== ADMIN USER ====================

//   static User getAdminUser() {
//     return User(
//       userID: 999,
//       name: 'Admin User',
//       email: 'admin@rechoice.com',
//       password: 'hashed_admin_password',
//       profilePic: 'https://via.placeholder.com/150',
//       bio: 'Platform Administrator',
//       reputationScore: 5.0,
//       status: UserStatus.active,
//       joinDate: DateTime(2023, 12, 1),
//       lastLogin: DateTime.now(),
//       role: UserRole.admin,
//       totalListings: 0,
//       totalPurchases: 0,
//     );
//   }

//   // ==================== HELPER METHODS ====================

//   // Get user by ID
//   static User? getUserById(int userID) {
//     try {
//       return getAllUsers().firstWhere((user) => user.userID == userID);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Get item by ID
//   static Item? getItemById(int itemID) {
//     try {
//       return getItemsForModeration().firstWhere(
//         (item) => item.itemID == itemID,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   // Search users
//   static List<User> searchUsers(String query) {
//     if (query.isEmpty) return getAllUsers();

//     final lowerQuery = query.toLowerCase();
//     return getAllUsers()
//         .where(
//           (user) =>
//               user.name.toLowerCase().contains(lowerQuery) ||
//               user.email.toLowerCase().contains(lowerQuery),
//         )
//         .toList();
//   }

//   // Filter users by status
//   static List<User> filterUsersByStatus(UserStatus status) {
//     return getAllUsers().where((user) => user.status == status).toList();
//   }

//   // Search items
//   static List<Item> searchItems(String query) {
//     if (query.isEmpty) return getItemsForModeration();

//     final lowerQuery = query.toLowerCase();
//     return getItemsForModeration()
//         .where(
//           (item) =>
//               item.title.toLowerCase().contains(lowerQuery) ||
//               item.brand.toLowerCase().contains(lowerQuery) ||
//               item.description.toLowerCase().contains(lowerQuery),
//         )
//         .toList();
//   }

//   // Filter items by moderation status
//   static List<Item> filterItemsByStatus(ModerationStatus status) {
//     return getItemsForModeration()
//         .where((item) => item.moderationStatus == status)
//         .toList();
//   }
// }
