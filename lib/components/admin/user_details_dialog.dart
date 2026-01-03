import 'package:flutter/material.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/viewmodels/users_view_model.dart';

class UserDetailsDialog {
  static String _getEnumValue(dynamic enumValue) {
    if (enumValue == null) return 'unknown';
    final parts = enumValue.toString().split('.');
    return parts.isNotEmpty ? parts.last : 'unknown';
  }

  static void show(BuildContext context, Users user) {
    final roleString = _getEnumValue(user.role);
    final statusString = _getEnumValue(user.status);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue,
              child: Text(
                UsersViewModel.getInitials(user.name),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 18)),
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'User ID', value: user.userID.toString()),
              _DetailRow(label: 'Role', value: roleString.toUpperCase()),
              _DetailRow(label: 'Status', value: statusString.toUpperCase()),
              _DetailRow(label: 'Join Date', value: user.joinDate.toString().split(' ').first),
              _DetailRow(label: 'Last Login', value: user.lastLogin.toString().split(' ').first),
              _DetailRow(label: 'Reputation', value: user.reputationScore.toStringAsFixed(1)),
              const Divider(height: 24),
              _DetailRow(label: 'Total Listings', value: user.totalListings.toString()),
              _DetailRow(label: 'Total Purchases', value: user.totalPurchases.toString()),
              _DetailRow(label: 'Total Sales', value: user.totalSales.toString()),
              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
                const Divider(height: 24),
                _DetailRow(label: 'Phone', value: user.phoneNumber!),
              ],
              if (user.address != null && user.address!.isNotEmpty)
                _DetailRow(label: 'Address', value: user.address!),
              if (user.bio.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Bio',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(user.bio, style: TextStyle(color: Colors.grey[700])),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}