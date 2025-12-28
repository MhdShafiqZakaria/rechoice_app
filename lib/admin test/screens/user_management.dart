// // screens/admin/user_management.dart
// import 'package:flutter/material.dart';
// import 'package:test_project/models/user.dart';
// import 'package:test_project/services/admin_dummy_data.dart';

// class UserManagementScreen extends StatefulWidget {
//   const UserManagementScreen({Key? key}) : super(key: key);

//   @override
//   State<UserManagementScreen> createState() => _UserManagementScreenState();
// }

// class _UserManagementScreenState extends State<UserManagementScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<User> _allUsers = [];
//   List<User> _filteredUsers = [];
//   String _selectedFilter = 'All Status';

//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }

//   void _loadUsers() {
//     setState(() {
//       _allUsers = AdminDummyDataService.getAllUsers();
//       _filteredUsers = _allUsers;
//     });
//   }

//   void _searchUsers(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredUsers = _allUsers;
//       } else {
//         _filteredUsers = AdminDummyDataService.searchUsers(query);
//       }
//       _applyStatusFilter();
//     });
//   }

//   void _applyStatusFilter() {
//     if (_selectedFilter == 'All Status') {
//       return;
//     }

//     setState(() {
//       if (_selectedFilter == 'Active') {
//         _filteredUsers = _filteredUsers.where((u) => u.isActive).toList();
//       } else if (_selectedFilter == 'Suspended') {
//         _filteredUsers = _filteredUsers.where((u) => u.isSuspended).toList();
//       }
//     });
//   }

//   void _showFilterDialog() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Filter by Status',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               _buildFilterOption('All Status'),
//               _buildFilterOption('Active'),
//               _buildFilterOption('Suspended'),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFilterOption(String label) {
//     return ListTile(
//       title: Text(label),
//       trailing: _selectedFilter == label
//           ? const Icon(Icons.check, color: Color(0xFF2E5C9A))
//           : null,
//       onTap: () {
//         setState(() {
//           _selectedFilter = label;
//           _searchUsers(_searchController.text);
//         });
//         Navigator.pop(context);
//       },
//     );
//   }

//   void _showUserActions(User user) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Actions for ${user.name}',
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ListTile(
//                 leading: const Icon(Icons.visibility, color: Color(0xFF4285F4)),
//                 title: const Text('View'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _viewUser(user);
//                 },
//               ),
//               if (user.isActive)
//                 ListTile(
//                   leading: const Icon(Icons.block, color: Color(0xFFDB4437)),
//                   title: const Text('Suspend'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _suspendUser(user);
//                   },
//                 ),
//               if (user.isSuspended)
//                 ListTile(
//                   leading: const Icon(
//                     Icons.check_circle,
//                     color: Color(0xFF0F9D58),
//                   ),
//                   title: const Text('Activate'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     _activateUser(user);
//                   },
//                 ),
//               ListTile(
//                 leading: const Icon(Icons.delete, color: Color(0xFFDB4437)),
//                 title: const Text('Delete'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _deleteUser(user);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _viewUser(User user) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(user.name),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildInfoRow('Email', user.email),
//                 _buildInfoRow('Role', user.role.toString().split('.').last),
//                 _buildInfoRow('Status', user.statusText),
//                 _buildInfoRow('Join Date', user.formattedJoinDate),
//                 _buildInfoRow('Last Login', user.formattedLastLogin),
//                 _buildInfoRow('Reputation', user.reputationScore.toString()),
//                 _buildInfoRow('Total Listings', user.totalListings.toString()),
//                 _buildInfoRow(
//                   'Total Purchases',
//                   user.totalPurchases.toString(),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Bio:',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(user.bio),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(color: Colors.black87)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _suspendUser(User user) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Suspend User'),
//           content: Text('Are you sure you want to suspend ${user.name}?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFDB4437),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);

//                 // UPDATE: Change status locally
//                 setState(() {
//                   final index = _allUsers.indexWhere(
//                     (u) => u.userID == user.userID,
//                   );
//                   if (index != -1) {
//                     _allUsers[index] = _allUsers[index].copyWith(
//                       status: UserStatus.suspended,
//                     );
//                   }

//                   final filteredIndex = _filteredUsers.indexWhere(
//                     (u) => u.userID == user.userID,
//                   );
//                   if (filteredIndex != -1) {
//                     _filteredUsers[filteredIndex] =
//                         _filteredUsers[filteredIndex].copyWith(
//                           status: UserStatus.suspended,
//                         );
//                   }
//                 });

//                 // TODO: Update user status in Firebase
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${user.name} has been suspended')),
//                 );
//               },
//               child: const Text('Suspend'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _activateUser(User user) {
//     setState(() {
//       final index = _allUsers.indexWhere((u) => u.userID == user.userID);
//       if (index != -1) {
//         _allUsers[index] = _allUsers[index].copyWith(status: UserStatus.active);
//       }

//       final filteredIndex = _filteredUsers.indexWhere(
//         (u) => u.userID == user.userID,
//       );
//       if (filteredIndex != -1) {
//         _filteredUsers[filteredIndex] = _filteredUsers[filteredIndex].copyWith(
//           status: UserStatus.active,
//         );
//       }
//     });

//     // TODO: Update user status in Firebase
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('${user.name} has been activated')));
//   }

//   void _deleteUser(User user) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete User'),
//           content: Text(
//             'Are you sure you want to delete ${user.name}? This action cannot be undone.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFDB4437),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);

//                 // UPDATE: Remove from local lists
//                 setState(() {
//                   _allUsers.removeWhere((u) => u.userID == user.userID);
//                   _filteredUsers.removeWhere((u) => u.userID == user.userID);
//                 });

//                 // TODO: Delete user from Firebase
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('${user.name} has been deleted')),
//                 );
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _exportUsers() {
//     // TODO: Implement export functionality
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Exporting users...')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2E5C9A),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'User Management',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           // Header Section
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'User Management',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Manage user accounts and permissions',
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 16),

//                 // Search Bar
//                 TextField(
//                   controller: _searchController,
//                   onChanged: _searchUsers,
//                   decoration: InputDecoration(
//                     hintText: 'Search users...',
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: _searchController.text.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () {
//                               _searchController.clear();
//                               _searchUsers('');
//                             },
//                           )
//                         : null,
//                     filled: true,
//                     fillColor: Colors.grey.shade100,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 14,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // Filter and Export Row
//                 Row(
//                   children: [
//                     Expanded(
//                       child: InkWell(
//                         onTap: _showFilterDialog,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _selectedFilter,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               const Icon(
//                                 Icons.arrow_drop_down,
//                                 color: Colors.black87,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: _exportUsers,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF4285F4),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 14,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         'Export',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Table Header
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               children: [
//                 const Expanded(
//                   flex: 3,
//                   child: Text(
//                     'USER',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 const Expanded(
//                   flex: 2,
//                   child: Text(
//                     'STATUS',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 const Expanded(
//                   flex: 2,
//                   child: Text(
//                     'JOIN DATE',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Text(
//                     'ACTIONS',
//                     textAlign: TextAlign.end,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // User List
//           Expanded(
//             child: _filteredUsers.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.people_outline,
//                           size: 80,
//                           color: Colors.grey.shade300,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No users found',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.separated(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     itemCount: _filteredUsers.length,
//                     separatorBuilder: (context, index) =>
//                         Divider(height: 1, color: Colors.grey.shade200),
//                     itemBuilder: (context, index) {
//                       final user = _filteredUsers[index];
//                       return _buildUserRow(user);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserRow(User user) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Row(
//         children: [
//           // User Info
//           Expanded(
//             flex: 3,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user.name,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   user.email,
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Expanded(
//             flex: 2,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: user.isActive
//                     ? Colors.green.shade50
//                     : Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 user.statusText,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: user.isActive
//                       ? Colors.green.shade700
//                       : Colors.red.shade700,
//                 ),
//               ),
//             ),
//           ),

//           // Join Date
//           Expanded(
//             flex: 2,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user.formattedJoinDate,
//                   style: const TextStyle(fontSize: 13, color: Colors.black87),
//                 ),
//                 Text(
//                   user.formattedLastLogin,
//                   style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
//                 ),
//               ],
//             ),
//           ),

//           // Actions
//           Expanded(
//             flex: 2,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => _viewUser(user),
//                   child: const Text(
//                     'View',
//                     style: TextStyle(
//                       color: Color(0xFF4285F4),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'suspend' && user.isActive) {
//                       _suspendUser(user);
//                     } else if (value == 'activate' && user.isSuspended) {
//                       _activateUser(user);
//                     } else if (value == 'delete') {
//                       _deleteUser(user);
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     if (user.isActive)
//                       const PopupMenuItem(
//                         value: 'suspend',
//                         child: Text('Suspend'),
//                       ),
//                     if (user.isSuspended)
//                       const PopupMenuItem(
//                         value: 'activate',
//                         child: Text('Activate'),
//                       ),
//                     const PopupMenuItem(
//                       value: 'delete',
//                       child: Text(
//                         'Delete',
//                         style: TextStyle(color: Color(0xFFDB4437)),
//                       ),
//                     ),
//                   ],
//                   icon: const Icon(Icons.more_vert),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }
