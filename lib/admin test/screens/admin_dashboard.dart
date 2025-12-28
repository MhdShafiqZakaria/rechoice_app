// // screens/admin/admin_dashboard.dart
// import 'package:flutter/material.dart';
// import 'package:test_project/models/activity.dart';
// import 'package:test_project/models/analytics.dart';
// import 'package:test_project/services/admin_dummy_data.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({Key? key}) : super(key: key);

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   int _selectedTabIndex = 0;
//   DashboardMetrics? _metrics;
//   List<Activity> _recentActivities = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() {
//     // Load from dummy data service (will be Firebase later)
//     setState(() {
//       _metrics = AdminDummyDataService.getDashboardMetrics();
//       _recentActivities = AdminDummyDataService.getRecentActivities();
//     });
//   }

//   void _onTabChanged(int index) {
//     setState(() {
//       _selectedTabIndex = index;
//     });
//     // TODO: Navigate to respective pages when they're ready
//     if (index == 1) {
//       // Navigate to User Management
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const Placeholder()),
//       );
//     } else if (index == 2) {
//       // Navigate to Listing Moderation
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const Placeholder()),
//       );
//     } else if (index == 3) {
//       // Navigate to Reports & Analytics
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const Placeholder()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2E5C9A),
//         elevation: 0,
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.admin_panel_settings,
//                 color: Color(0xFF2E5C9A),
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Text(
//               'Admin Dashboard',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () {
//               // TODO: Implement logout
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Logout clicked')),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Tab Navigation
//           Container(
//             color: Colors.white,
//             child: Row(
//               children: [
//                 _buildTab(0, Icons.dashboard, 'Dashboard'),
//                 _buildTab(1, Icons.people, 'Users'),
//                 _buildTab(2, Icons.folder, 'Listings'),
//                 _buildTab(3, Icons.access_time, 'Reports'),
//               ],
//             ),
//           ),
          
//           // Content
//           Expanded(
//             child: _metrics == null
//                 ? const Center(child: CircularProgressIndicator())
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Page Title
//                         const Text(
//                           'Dashboard Overview',
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Monitor your platform performance and key metrics',
//                           style: TextStyle(
//                             fontSize: 15,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Metrics Cards
//                         GridView.count(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                           childAspectRatio: 1.4,
//                           children: [
//                             _buildMetricCard(
//                               title: 'Total Users',
//                               value: _metrics!.totalUsersFormatted,
//                               growth: _metrics!.usersGrowthFormatted,
//                               isPositive: _metrics!.isUsersGrowthPositive,
//                               icon: Icons.person,
//                               color: const Color(0xFF4285F4),
//                             ),
//                             _buildMetricCard(
//                               title: 'Active Users',
//                               value: _metrics!.activeUsersFormatted,
//                               growth: _metrics!.activeUsersGrowthFormatted,
//                               isPositive: _metrics!.isActiveUsersGrowthPositive,
//                               icon: Icons.person_add,
//                               color: const Color(0xFF0F9D58),
//                             ),
//                             _buildMetricCard(
//                               title: 'Total Listings',
//                               value: _metrics!.totalListingsFormatted,
//                               growth: _metrics!.listingsGrowthFormatted,
//                               isPositive: _metrics!.isListingsGrowthPositive,
//                               icon: Icons.shopping_bag,
//                               color: const Color(0xFFF4B400),
//                             ),
//                             _buildMetricCard(
//                               title: 'Pending Reports',
//                               value: _metrics!.pendingReportsFormatted,
//                               growth: _metrics!.newReportsFormatted,
//                               isPositive: false,
//                               icon: Icons.warning,
//                               color: const Color(0xFFDB4437),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 32),

//                         // Recent Activity
//                         const Text(
//                           'Recent Activity',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: ListView.separated(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemCount: _recentActivities.length > 5 
//                                 ? 5 
//                                 : _recentActivities.length,
//                             separatorBuilder: (context, index) => Divider(
//                               height: 1,
//                               color: Colors.grey.shade200,
//                             ),
//                             itemBuilder: (context, index) {
//                               final activity = _recentActivities[index];
//                               return _buildActivityItem(activity);
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTab(int index, IconData icon, String label) {
//     final isSelected = _selectedTabIndex == index;
//     return Expanded(
//       child: InkWell(
//         onTap: () => _onTabChanged(index),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: isSelected ? const Color(0xFF2E5C9A) : Colors.transparent,
//                 width: 3,
//               ),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected ? const Color(0xFF2E5C9A) : Colors.grey.shade600,
//                 size: 24,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                   color: isSelected ? const Color(0xFF2E5C9A) : Colors.grey.shade600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricCard({
//     required String title,
//     required String value,
//     required String growth,
//     required bool isPositive,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey.shade700,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Icon(
//                   icon,
//                   color: color,
//                   size: 24,
//                 ),
//               ),
//             ],
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 growth,
//                 style: TextStyle(
//                   fontSize: 13,
//                   color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 title == 'Pending Reports' ? '' : 'from last month',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey.shade500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityItem(Activity activity) {
//     Color iconColor;
//     Color backgroundColor;

//     switch (activity.colorType) {
//       case 'blue':
//         iconColor = const Color(0xFF4285F4);
//         backgroundColor = const Color(0xFF4285F4);
//         break;
//       case 'green':
//         iconColor = const Color(0xFF0F9D58);
//         backgroundColor = const Color(0xFF0F9D58);
//         break;
//       case 'red':
//         iconColor = const Color(0xFFDB4437);
//         backgroundColor = const Color(0xFFDB4437);
//         break;
//       case 'orange':
//         iconColor = const Color(0xFFF4B400);
//         backgroundColor = const Color(0xFFF4B400);
//         break;
//       default:
//         iconColor = Colors.grey;
//         backgroundColor = Colors.grey;
//     }

//     IconData activityIcon;
//     switch (activity.iconType) {
//       case 'person_add':
//         activityIcon = Icons.person_add;
//         break;
//       case 'check_circle':
//         activityIcon = Icons.check_circle;
//         break;
//       case 'cancel':
//         activityIcon = Icons.cancel;
//         break;
//       case 'warning':
//         activityIcon = Icons.warning;
//         break;
//       case 'block':
//         activityIcon = Icons.block;
//         break;
//       case 'verified':
//         activityIcon = Icons.verified;
//         break;
//       case 'shopping_cart':
//         activityIcon = Icons.shopping_cart;
//         break;
//       case 'add_box':
//         activityIcon = Icons.add_box;
//         break;
//       case 'delete':
//         activityIcon = Icons.delete;
//         break;
//       default:
//         activityIcon = Icons.info;
//     }

//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       leading: Container(
//         width: 48,
//         height: 48,
//         decoration: BoxDecoration(
//           color: backgroundColor.withOpacity(0.1),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           activityIcon,
//           color: iconColor,
//           size: 24,
//         ),
//       ),
//       title: Text(
//         activity.title,
//         style: const TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//           color: Colors.black87,
//         ),
//       ),
//       subtitle: Text(
//         activity.description,
//         style: TextStyle(
//           fontSize: 13,
//           color: Colors.grey.shade600,
//         ),
//       ),
//       trailing: Text(
//         activity.timeAgo,
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.grey.shade500,
//         ),
//       ),
//     );
//   }
// }