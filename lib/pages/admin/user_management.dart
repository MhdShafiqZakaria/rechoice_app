import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/admin/admin_shared_widget.dart';
import 'package:rechoice_app/components/admin/user_details_dialog.dart';
import 'package:rechoice_app/components/admin/user_dialogs.dart';
import 'package:rechoice_app/components/admin/user_filter_bar.dart';
import 'package:rechoice_app/components/admin/user_row.dart';
import 'package:rechoice_app/components/admin/user_stats_card.dart';
import 'package:rechoice_app/components/admin/user_table_header.dart';
import 'package:rechoice_app/models/services/authenticate.dart';
import 'package:rechoice_app/models/viewmodels/users_view_model.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/utils/export_utils.dart';
import 'package:rechoice_app/pages/auth/loading_page.dart';
import 'package:rechoice_app/utils/logger.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final AuthService _authService = AuthService();
  String selectedStatus = 'All Status';
  String selectedRole = 'All Roles';
  String searchQuery = '';
  List<Users> filteredUsers = [];
  bool isLoading = true;
  Map<String, int> statusCounts = {};
  Map<String, int> roleCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  Future<void> _loadUsers() async {
    try {
      await _authService.verifyAdminAccess();
      final usersVM = context.read<UsersViewModel>();
      await usersVM.loadUsers();
      if (mounted) {
        setState(() {
          _updateFilteredData();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied: Admin only'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateFilteredData() {
    final usersVM = Provider.of<UsersViewModel>(context, listen: false);

    final rawStatusCounts = usersVM.getStatusCounts();
    final rawRoleCounts = usersVM.getRoleCounts();

    statusCounts = {
      'active': rawStatusCounts['active'] ?? rawStatusCounts['Active'] ?? 0,
      'suspended':
          rawStatusCounts['suspended'] ?? rawStatusCounts['Suspended'] ?? 0,
      'deleted':
          rawStatusCounts['deleted'] ??
          rawStatusCounts['Deleted'] ??
          rawStatusCounts['Inactive'] ??
          0,
    };

    roleCounts = {
      'user':
          rawRoleCounts['user'] ??
          rawRoleCounts['User'] ??
          rawRoleCounts['buyer'] ??
          rawRoleCounts['Buyer'] ??
          0,
      'seller': rawRoleCounts['seller'] ?? rawRoleCounts['Seller'] ?? 0,
      'admin': rawRoleCounts['admin'] ?? rawRoleCounts['Admin'] ?? 0,
    };

    String? backendStatus = _mapStatusToBackend(selectedStatus);
    String? backendRole = _mapRoleToBackend(selectedRole);

    try {
      filteredUsers = usersVM.getFilteredUsers(
        searchQuery: searchQuery,
        status: backendStatus,
        role: backendRole,
      );
    } catch (e) {
      AppLogger.error('UserManagement: Error filtering users', e);
      filteredUsers = [];
    }
  }

  String? _mapStatusToBackend(String uiStatus) {
    switch (uiStatus) {
      case 'Active':
        return 'active';
      case 'Suspended':
        return 'suspended';
      case 'Inactive':
        return 'deleted';
      default:
        return null;
    }
  }

  String? _mapRoleToBackend(String uiRole) {
    switch (uiRole) {
      case 'Buyer':
        return 'buyer';
      case 'Seller':
        return 'seller';
      case 'Admin':
        return 'admin';
      default:
        return null;
    }
  }

  Future<void> _exportUsers() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exporting users...'),
          duration: Duration(seconds: 2),
        ),
      );

      final filePath = await ExportUtils.exportUsersToCSV(filteredUsers);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Users exported to ${filePath.split('/').last}'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminSliverScaffold(
      selectedTabIndex: 1,
      title: 'User Management',
      subtitle: 'Manage user accounts and permissions',
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLoading)
              UserStatsCards(
                roleCounts: roleCounts,
                statusCounts: statusCounts,
              ),
            const SizedBox(height: 24),

            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _updateFilteredData();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            _updateFilteredData();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            UserFiltersBar(
              selectedStatus: selectedStatus,
              selectedRole: selectedRole,
              onStatusChanged: (value) {
                setState(() {
                  selectedStatus = value;
                  _updateFilteredData();
                });
              },
              onRoleChanged: (value) {
                setState(() {
                  selectedRole = value;
                  _updateFilteredData();
                });
              },
              onExport: _exportUsers,
            ),
            const SizedBox(height: 24),

            Text(
              'Showing ${filteredUsers.length} user${filteredUsers.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            const UserTableHeader(),

            Flexible(
              child: isLoading
                  ? const Center(child: LoadingPage())
                  : filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isNotEmpty
                                ? 'No users match your search'
                                : 'No users found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (searchQuery.isNotEmpty ||
                              selectedStatus != 'All Status' ||
                              selectedRole != 'All Roles') ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                  selectedStatus = 'All Status';
                                  selectedRole = 'All Roles';
                                  _updateFilteredData();
                                });
                              },
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Builder(
                        builder: (context) {
                          // Create a snapshot of the list to prevent index issues
                          final usersList = List<Users>.from(filteredUsers);
                          final itemCount = usersList.length;

                          return ListView.builder(
                            key: ValueKey(
                              itemCount,
                            ), // Force rebuild when count changes
                            itemCount: itemCount,
                            itemBuilder: (context, index) {
                              // Safety check to prevent index out of range
                              if (index < 0 || index >= usersList.length) {
                                return const SizedBox.shrink();
                              }

                              try {
                                final user = usersList[index];
                                return UserRow(
                                  key: ValueKey(
                                    user.uid,
                                  ), // Unique key for each row
                                  user: user,
                                  onView: () =>
                                      UserDetailsDialog.show(context, user),
                                  onSuspend: () => _handleSuspend(user),
                                  onActivate: () => _handleActivate(user),
                                  onDelete: () => _handleDelete(user),
                                  onChangeRole: () => _handleChangeRole(user),
                                );
                              } catch (e) {
                                print(
                                  'Error rendering user at index $index: $e',
                                );
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'Error loading user',
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleChangeRole(Users user) async {
    final selectedRole = await UserDialogs.showChangeRoleDialog(context, user);

    if (selectedRole != null &&
        selectedRole != user.role.toString().split('.').last) {
      try {
        await _authService.updateUserRole(user.uid, selectedRole);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Role updated to ${selectedRole.toUpperCase()}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update role: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSuspend(Users user) async {
    final confirm = await UserDialogs.showSuspendDialog(context, user);

    if (confirm == true) {
      try {
        await _authService.suspendUser(user.uid);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User suspended'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to suspend: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleActivate(Users user) async {
    final confirm = await UserDialogs.showActivateDialog(context, user);

    if (confirm == true) {
      try {
        await _authService.activateUser(user.uid);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User activated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to activate: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDelete(Users user) async {
    final confirm = await UserDialogs.showDeleteDialog(context, user);

    if (confirm == true) {
      try {
        await _authService.permanentlyDeleteAccount(uid: user.uid);
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted permanently'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
