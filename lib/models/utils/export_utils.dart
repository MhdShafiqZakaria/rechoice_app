import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rechoice_app/models/model/users_model.dart';

class ExportUtils {
  /// Sanitize CSV fields to prevent formula injection attacks
  /// Prefixes cells starting with formula characters (=, +, -, @, etc.) with a single quote
  /// This is the standard defense against CSV/Excel injection
  static String _sanitizeCSVField(dynamic value) {
    if (value == null) return 'N/A';
    
    final stringValue = value.toString().trim();
    if (stringValue.isEmpty) return '';
    
    // Check if the field starts with formula injection characters
    final firstChar = stringValue[0];
    if (firstChar == '=' || 
        firstChar == '+' || 
        firstChar == '-' || 
        firstChar == '@' ||
        firstChar == '\t' ||
        firstChar == '\r') {
      // Prefix with single quote to neutralize formula execution
      // Spreadsheet applications will treat this as literal text
      return "'$stringValue";
    }
    
    return stringValue;
  }
  /// Export users list to CSV file
  static Future<String> exportUsersToCSV(List<Users> users) async {
    try {
      // Prepare CSV headers
      List<List<dynamic>> csvData = [
        [
          'User ID',
          'Name',
          'Email',
          'Status',
          'Role',
          'Reputation Score',
          'Total Listings',
          'Total Purchases',
          'Total Sales',
          'Join Date',
          'Last Login',
          'Phone',
          'Address',
        ],
      ];

      // Add user data rows
      for (var user in users) {
        csvData.add([
          _sanitizeCSVField(user.userID),
          _sanitizeCSVField(user.name),
          _sanitizeCSVField(user.email),
          _sanitizeCSVField(user.status.toString().split('.').last),
          _sanitizeCSVField(user.role.toString().split('.').last),
          user.reputationScore.toStringAsFixed(2),
          user.totalListings,
          user.totalPurchases,
          user.totalSales,
          _sanitizeCSVField(user.joinDate.toString().split(' ')[0]),
          _sanitizeCSVField(user.lastLogin.toString().split(' ')[0]),
          _sanitizeCSVField(user.phoneNumber ?? 'N/A'),
          _sanitizeCSVField(user.address ?? 'N/A'),
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Get downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/users_export_$timestamp.csv';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (e) {
      throw Exception('Failed to export users: $e');
    }
  }

  /// Export listings to CSV file
  static Future<String> exportListingsToCSV(List<Map<String, dynamic>> listings) async {
    try {
      // Prepare CSV headers
      List<List<dynamic>> csvData = [
        [
          'Listing ID',
          'Title',
          'Category',
          'Price',
          'Status',
          'Seller',
          'Created Date',
          'Views',
          'Description',
        ],
      ];

      // Add listing data rows
      for (var listing in listings) {
        csvData.add([
          _sanitizeCSVField(listing['id'] ?? 'N/A'),
          _sanitizeCSVField(listing['title'] ?? 'N/A'),
          _sanitizeCSVField(listing['category'] ?? 'N/A'),
          '\$${(listing['price'] ?? 0).toStringAsFixed(2)}',
          _sanitizeCSVField(listing['status'] ?? 'N/A'),
          _sanitizeCSVField(listing['sellerName'] ?? 'N/A'),
          _sanitizeCSVField((listing['createdAt'] as DateTime?)?.toString().split(' ')[0] ?? 'N/A'),
          listing['views'] ?? 0,
          _sanitizeCSVField((listing['description'] ?? 'N/A').toString().replaceAll('\n', ' ')),
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Get downloads directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/listings_export_$timestamp.csv';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (e) {
      throw Exception('Failed to export listings: $e');
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
