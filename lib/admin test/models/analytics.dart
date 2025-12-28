// models/analytics.dart

class DashboardMetrics {
  final int totalUsers;
  final int activeUsers;
  final int totalListings;
  final int pendingReports;
  
  // Growth percentages from last month
  final double usersGrowth;
  final double activeUsersGrowth;
  final double listingsGrowth;
  final int newReports; // New reports count (not percentage)

  DashboardMetrics({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalListings,
    required this.pendingReports,
    this.usersGrowth = 0.0,
    this.activeUsersGrowth = 0.0,
    this.listingsGrowth = 0.0,
    this.newReports = 0,
  });

  // Firebase ready - fromJson
  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalUsers: json['totalUsers'],
      activeUsers: json['activeUsers'],
      totalListings: json['totalListings'],
      pendingReports: json['pendingReports'],
      usersGrowth: json['usersGrowth']?.toDouble() ?? 0.0,
      activeUsersGrowth: json['activeUsersGrowth']?.toDouble() ?? 0.0,
      listingsGrowth: json['listingsGrowth']?.toDouble() ?? 0.0,
      newReports: json['newReports'] ?? 0,
    );
  }

  // Firebase ready - toJson
  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalListings': totalListings,
      'pendingReports': pendingReports,
      'usersGrowth': usersGrowth,
      'activeUsersGrowth': activeUsersGrowth,
      'listingsGrowth': listingsGrowth,
      'newReports': newReports,
    };
  }

  // Format growth percentage with + or - sign
  String formatGrowth(double growth) {
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}%';
  }

  // Get formatted strings for UI
  String get totalUsersFormatted => totalUsers.toString();
  String get activeUsersFormatted => activeUsers.toString();
  String get totalListingsFormatted => totalListings.toString();
  String get pendingReportsFormatted => pendingReports.toString();

  String get usersGrowthFormatted => formatGrowth(usersGrowth);
  String get activeUsersGrowthFormatted => formatGrowth(activeUsersGrowth);
  String get listingsGrowthFormatted => formatGrowth(listingsGrowth);
  String get newReportsFormatted => '+$newReports new reports';

  // Check if growth is positive
  bool get isUsersGrowthPositive => usersGrowth > 0;
  bool get isActiveUsersGrowthPositive => activeUsersGrowth > 0;
  bool get isListingsGrowthPositive => listingsGrowth > 0;

  // Get user activity rate (percentage of active users)
  double get activityRate {
    if (totalUsers == 0) return 0.0;
    return (activeUsers / totalUsers) * 100;
  }

  String get activityRateFormatted => '${activityRate.toStringAsFixed(1)}%';

  // Copy with method
  DashboardMetrics copyWith({
    int? totalUsers,
    int? activeUsers,
    int? totalListings,
    int? pendingReports,
    double? usersGrowth,
    double? activeUsersGrowth,
    double? listingsGrowth,
    int? newReports,
  }) {
    return DashboardMetrics(
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      totalListings: totalListings ?? this.totalListings,
      pendingReports: pendingReports ?? this.pendingReports,
      usersGrowth: usersGrowth ?? this.usersGrowth,
      activeUsersGrowth: activeUsersGrowth ?? this.activeUsersGrowth,
      listingsGrowth: listingsGrowth ?? this.listingsGrowth,
      newReports: newReports ?? this.newReports,
    );
  }
}

// Report Analytics Model
class ReportAnalytics {
  final int totalReports;
  final int resolvedReports;
  final int pendingReports;

  ReportAnalytics({
    required this.totalReports,
    required this.resolvedReports,
    required this.pendingReports,
  });

  // Firebase ready - fromJson
  factory ReportAnalytics.fromJson(Map<String, dynamic> json) {
    return ReportAnalytics(
      totalReports: json['totalReports'],
      resolvedReports: json['resolvedReports'],
      pendingReports: json['pendingReports'],
    );
  }

  // Firebase ready - toJson
  Map<String, dynamic> toJson() {
    return {
      'totalReports': totalReports,
      'resolvedReports': resolvedReports,
      'pendingReports': pendingReports,
    };
  }

  // Get resolution rate percentage
  double get resolutionRate {
    if (totalReports == 0) return 0.0;
    return (resolvedReports / totalReports) * 100;
  }

  String get resolutionRateFormatted => '${resolutionRate.toStringAsFixed(1)}%';

  // Get pending rate percentage
  double get pendingRate {
    if (totalReports == 0) return 0.0;
    return (pendingReports / totalReports) * 100;
  }

  String get pendingRateFormatted => '${pendingRate.toStringAsFixed(1)}%';

  // Formatted strings
  String get totalReportsFormatted => totalReports.toString();
  String get resolvedReportsFormatted => resolvedReports.toString();
  String get pendingReportsFormatted => pendingReports.toString();

  // Copy with method
  ReportAnalytics copyWith({
    int? totalReports,
    int? resolvedReports,
    int? pendingReports,
  }) {
    return ReportAnalytics(
      totalReports: totalReports ?? this.totalReports,
      resolvedReports: resolvedReports ?? this.resolvedReports,
      pendingReports: pendingReports ?? this.pendingReports,
    );
  }
}

// Monthly Analytics Model (for charts/graphs if needed later)
class MonthlyAnalytics {
  final String month; // e.g., "2024-03"
  final int newUsers;
  final int newListings;
  final int completedTransactions;
  final int newReports;

  MonthlyAnalytics({
    required this.month,
    required this.newUsers,
    required this.newListings,
    required this.completedTransactions,
    required this.newReports,
  });

  // Firebase ready - fromJson
  factory MonthlyAnalytics.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalytics(
      month: json['month'],
      newUsers: json['newUsers'],
      newListings: json['newListings'],
      completedTransactions: json['completedTransactions'],
      newReports: json['newReports'],
    );
  }

  // Firebase ready - toJson
  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'newUsers': newUsers,
      'newListings': newListings,
      'completedTransactions': completedTransactions,
      'newReports': newReports,
    };
  }

  // Get formatted month name (e.g., "March 2024")
  String get formattedMonth {
    final parts = month.split('-');
    if (parts.length != 2) return month;
    
    final year = parts[0];
    final monthNum = int.tryParse(parts[1]) ?? 1;
    
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${monthNames[monthNum - 1]} $year';
  }

  // Copy with method
  MonthlyAnalytics copyWith({
    String? month,
    int? newUsers,
    int? newListings,
    int? completedTransactions,
    int? newReports,
  }) {
    return MonthlyAnalytics(
      month: month ?? this.month,
      newUsers: newUsers ?? this.newUsers,
      newListings: newListings ?? this.newListings,
      completedTransactions: completedTransactions ?? this.completedTransactions,
      newReports: newReports ?? this.newReports,
    );
  }
}

// Extension for list operations
extension MonthlyAnalyticsListExtension on List<MonthlyAnalytics> {
  // Get last N months
  List<MonthlyAnalytics> lastNMonths(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }

  // Calculate total for a metric
  int get totalNewUsers => fold(0, (sum, item) => sum + item.newUsers);
  int get totalNewListings => fold(0, (sum, item) => sum + item.newListings);
  int get totalTransactions => fold(0, (sum, item) => sum + item.completedTransactions);
  int get totalNewReports => fold(0, (sum, item) => sum + item.newReports);

  // Calculate average
  double get averageNewUsers => length > 0 ? totalNewUsers / length : 0.0;
  double get averageNewListings => length > 0 ? totalNewListings / length : 0.0;
}