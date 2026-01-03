import 'package:flutter/material.dart';
import 'package:rechoice_app/models/model/users_model.dart';

class UserDialogs {
  static String _getEnumValue(dynamic enumValue) {
    if (enumValue == null) return 'unknown';
    final parts = enumValue.toString().split('.');
    return parts.isNotEmpty ? parts.last : 'unknown';
  }

  static Future<String?> showChangeRoleDialog(
    BuildContext context,
    Users user,
  ) {
    final currentRole = _getEnumValue(user.role);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Role for ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Buyer'),
              leading: Radio<String>(
                value: 'buyer',
                groupValue: currentRole,
                onChanged: (_) => Navigator.pop(context, 'buyer'),
              ),
            ),
            ListTile(
              title: const Text('Seller'),
              leading: Radio<String>(
                value: 'seller',
                groupValue: currentRole,
                onChanged: (_) => Navigator.pop(context, 'seller'),
              ),
            ),
            ListTile(
              title: const Text('Admin'),
              leading: Radio<String>(
                value: 'admin',
                groupValue: currentRole,
                onChanged: (_) => Navigator.pop(context, 'admin'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showSuspendDialog(BuildContext context, Users user) {
    return _showConfirmDialog(
      context,
      'Suspend User',
      'Suspend ${user.name}? They will not be able to access the platform.',
      'Suspend',
      Colors.orange,
    );
  }

  static Future<bool?> showActivateDialog(BuildContext context, Users user) {
    return _showConfirmDialog(
      context,
      'Activate User',
      'Activate ${user.name}? They will regain full access.',
      'Activate',
      Colors.green,
    );
  }

  static Future<bool?> showDeleteDialog(BuildContext context, Users user) {
    return _showConfirmDialog(
      context,
      'Delete User',
      'Permanently delete ${user.name}? This cannot be undone.',
      'Delete',
      Colors.red,
    );
  }

  static Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    String actionLabel,
    Color actionColor,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: actionColor),
            child: Text(
              actionLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}