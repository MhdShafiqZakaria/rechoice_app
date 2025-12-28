// models/activity.dart

enum ActivityType {
  userRegistration,
  listingApproved,
  listingRejected,
  reportReceived,
  userSuspended,
  userActivated,
  purchaseCompleted,
  listingCreated,
  listingDeleted,
}

class Activity {
  final int activityID;
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final int? userID; // User who triggered this activity
  final int? itemID; // Related item (if applicable)
  final int? targetUserID; // Target user (for admin actions)

  Activity({
    required this.activityID,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.userID,
    this.itemID,
    this.targetUserID,
  });

  // Firebase ready - fromJson
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      activityID: json['activityID'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${json['type']}',
        orElse: () => ActivityType.userRegistration,
      ),
      title: json['title'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      userID: json['userID'],
      itemID: json['itemID'],
      targetUserID: json['targetUserID'],
    );
  }

  // Firebase ready - toJson
  Map<String, dynamic> toJson() {
    return {
      'activityID': activityID,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userID': userID,
      'itemID': itemID,
      'targetUserID': targetUserID,
    };
  }

  // Get icon for activity type
  String get iconType {
    switch (type) {
      case ActivityType.userRegistration:
        return 'person_add';
      case ActivityType.listingApproved:
        return 'check_circle';
      case ActivityType.listingRejected:
        return 'cancel';
      case ActivityType.reportReceived:
        return 'warning';
      case ActivityType.userSuspended:
        return 'block';
      case ActivityType.userActivated:
        return 'verified';
      case ActivityType.purchaseCompleted:
        return 'shopping_cart';
      case ActivityType.listingCreated:
        return 'add_box';
      case ActivityType.listingDeleted:
        return 'delete';
    }
  }

  // Get color for activity type
  String get colorType {
    switch (type) {
      case ActivityType.userRegistration:
        return 'blue';
      case ActivityType.listingApproved:
        return 'green';
      case ActivityType.listingRejected:
        return 'red';
      case ActivityType.reportReceived:
        return 'red';
      case ActivityType.userSuspended:
        return 'red';
      case ActivityType.userActivated:
        return 'green';
      case ActivityType.purchaseCompleted:
        return 'green';
      case ActivityType.listingCreated:
        return 'blue';
      case ActivityType.listingDeleted:
        return 'orange';
    }
  }

  // Get time ago string (e.g., "2 min ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} sec ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  // Get formatted timestamp
  String get formattedTimestamp {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Check if activity is recent (within last hour)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 1;

  // Check if activity is critical (needs attention)
  bool get isCritical {
    return type == ActivityType.reportReceived ||
        type == ActivityType.userSuspended;
  }

  // Copy with method
  Activity copyWith({
    int? activityID,
    ActivityType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    int? userID,
    int? itemID,
    int? targetUserID,
  }) {
    return Activity(
      activityID: activityID ?? this.activityID,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      userID: userID ?? this.userID,
      itemID: itemID ?? this.itemID,
      targetUserID: targetUserID ?? this.targetUserID,
    );
  }
}

// Extension for list operations
extension ActivityListExtension on List<Activity> {
  List<Activity> get recentActivities {
    final sorted = List<Activity>.from(this);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  List<Activity> get criticalActivities {
    return where((a) => a.isCritical).toList();
  }

  List<Activity> byType(ActivityType type) {
    return where((a) => a.type == type).toList();
  }

  List<Activity> byUser(int userID) {
    return where((a) => a.userID == userID).toList();
  }

  List<Activity> todayActivities() {
    final today = DateTime.now();
    return where(
      (a) =>
          a.timestamp.year == today.year &&
          a.timestamp.month == today.month &&
          a.timestamp.day == today.day,
    ).toList();
  }
}
