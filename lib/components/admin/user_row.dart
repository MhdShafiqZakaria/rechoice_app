import 'package:flutter/material.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/viewmodels/users_view_model.dart';

class UserRow extends StatelessWidget {
  final Users user;
  final VoidCallback onView;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;
  final VoidCallback onDelete;
  final VoidCallback onChangeRole;

  const UserRow({
    super.key,
    required this.user,
    required this.onView,
    required this.onSuspend,
    required this.onActivate,
    required this.onDelete,
    required this.onChangeRole,
  });

  String _getEnumValue(dynamic enumValue) {
    if (enumValue == null) return 'unknown';
    try {
      final str = enumValue.toString();
      final parts = str.split('.');
      if (parts.length > 1) {
        return parts[1];
      }
      return parts.isNotEmpty ? parts[0] : 'unknown';
    } catch (e) {
      print('Error getting enum value: $e');
      return 'unknown';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateStr = date.toString();
      final parts = dateStr.split(' ');
      return parts.isNotEmpty ? parts[0] : 'N/A';
    } catch (e) {
      print('Error formatting date: $e');
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStatusString = _getEnumValue(user.status);
    final userRoleString = _getEnumValue(user.role);
    final isSuspended = userStatusString.toLowerCase() == 'suspended';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    UsersViewModel.getInitials(user.name),
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(userRoleString).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userRoleString.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getRoleColor(userRoleString),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSuspended ? Colors.orange : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                userStatusString.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(user.joinDate),
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    onView();
                    break;
                  case 'role':
                    onChangeRole();
                    break;
                  case 'suspend':
                    onSuspend();
                    break;
                  case 'activate':
                    onActivate();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(Icons.badge, size: 18, color: Colors.purple),
                      SizedBox(width: 8),
                      Text('Change Role'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                if (isSuspended)
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 18, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Activate'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Suspend'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.purple;
      case 'buyer':
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}