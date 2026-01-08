import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';

class DashboardMetrics {
  final int totalUsers;
  final int activeUsers;
  final int totalListings;
  final int pendingReports;
  final List<RecentActivity> recentActivity;

  DashboardMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalListings,
    required this.pendingReports,
    required this.recentActivity,
  });
}

class RecentActivity {
  final String id;
  final String type; // 'user_registration', 'listing_approved', 'report_filed', etc.
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String iconType; // 'user', 'listing', 'report', 'message'

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.iconType,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class DashboardService {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DashboardService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Fetch all dashboard metrics
  Future<DashboardMetrics> getDashboardMetrics() async {
    try {
      // Fetch metrics in parallel for better performance
      final results = await Future.wait([
        _getTotalUsers(),
        _getActiveUsersCount(),
        _getTotalListingsCount(),
        _getPendingReportsCount(),
        _getRecentActivity(),
      ]);

      return DashboardMetrics(
        totalUsers: results[0] as int,
        activeUsers: results[1] as int,
        totalListings: results[2] as int,
        pendingReports: results[3] as int,
        recentActivity: results[4] as List<RecentActivity>,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get total user count
  Future<int> _getTotalUsers() async {
    try {
      final snapshot = await _db.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get active users count (status == 'active')
  Future<int> _getActiveUsersCount() async {
    try {
      final snapshot = await _firestoreService.getUsersByStatus('active');
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get total listings count
  Future<int> _getTotalListingsCount() async {
    try {
      final snapshot = await _db.collection('items').get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get pending reports count
  Future<int> _getPendingReportsCount() async {
    try {
      final snapshot = await _db
          .collection('reports')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get recent activity (last 10 activities)
  Future<List<RecentActivity>> _getRecentActivity() async {
    try {
      final activities = <RecentActivity>[];

      // Fetch recent user registrations
      final userSnapshot = await _db
          .collection('users')
          .orderBy('joinDate', descending: true)
          .limit(5)
          .get();

      for (final doc in userSnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now();

        activities.add(RecentActivity(
          id: doc.id,
          type: 'user_registration',
          title: 'New user registration',
          subtitle: '${data['name'] ?? 'User'} joined the platform',
          timestamp: timestamp,
          iconType: 'user',
        ));
      }

      // Fetch recent listings
      final listingSnapshot = await _db
          .collection('items')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      for (final doc in listingSnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        activities.add(RecentActivity(
          id: doc.id,
          type: 'listing_created',
          title: 'New listing',
          subtitle: '${data['title'] ?? 'Item'} was posted',
          timestamp: timestamp,
          iconType: 'listing',
        ));
      }

      // Fetch recent reports
      final reportSnapshot = await _db
          .collection('reports')
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      for (final doc in reportSnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

        activities.add(RecentActivity(
          id: doc.id,
          type: 'report_filed',
          title: 'Report filed',
          subtitle: '${data['reportType'] ?? 'Report'} - ${data['reason'] ?? 'No reason'}',
          timestamp: timestamp,
          iconType: 'report',
        ));
      }

      // Sort by timestamp (most recent first) and limit to 10
      activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return activities.take(10).toList();
    } catch (e) {
      return [];
    }
  }
}
