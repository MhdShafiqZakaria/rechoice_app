// // screens/admin/reports_analytics.dart
// import 'package:flutter/material.dart';
// import 'package:test_project/models/analytics.dart';
// import 'package:test_project/services/admin_dummy_data.dart';

// class ReportsAnalyticsScreen extends StatefulWidget {
//   const ReportsAnalyticsScreen({Key? key}) : super(key: key);

//   @override
//   State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
// }

// class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
//   ReportAnalytics? _reportAnalytics;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   void _loadData() {
//     setState(() {
//       _reportAnalytics = AdminDummyDataService.getReportAnalytics();
//     });
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
//           'Reports & Analytics',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: _reportAnalytics == null
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Page Title
//                   const Text(
//                     'Reports & Analytics',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Monitor reports and generate analytics',
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // Report Summary Card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 10,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Report Summary',
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 24),

//                         // Total Reports
//                         _buildSummaryRow(
//                           label: 'Total Reports',
//                           value: _reportAnalytics!.totalReportsFormatted,
//                           valueColor: Colors.black87,
//                         ),
//                         const SizedBox(height: 20),

//                         // Resolved Reports
//                         _buildSummaryRow(
//                           label: 'Resolved',
//                           value: _reportAnalytics!.resolvedReportsFormatted,
//                           valueColor: const Color(0xFF0F9D58),
//                         ),
//                         const SizedBox(height: 20),

//                         // Pending Reports
//                         _buildSummaryRow(
//                           label: 'Pending',
//                           value: _reportAnalytics!.pendingReportsFormatted,
//                           valueColor: const Color(0xFFDB4437),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Statistics Cards
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildStatCard(
//                           title: 'Resolution Rate',
//                           value: _reportAnalytics!.resolutionRateFormatted,
//                           icon: Icons.check_circle,
//                           color: const Color(0xFF0F9D58),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: _buildStatCard(
//                           title: 'Pending Rate',
//                           value: _reportAnalytics!.pendingRateFormatted,
//                           icon: Icons.pending,
//                           color: const Color(0xFFF4B400),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 32),

//                   // Action Buttons
//                   const Text(
//                     'Quick Actions',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   _buildActionButton(
//                     icon: Icons.download,
//                     label: 'Export Report',
//                     subtitle: 'Download detailed analytics report',
//                     color: const Color(0xFF4285F4),
//                     onTap: () {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Exporting report...')),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 12),

//                   _buildActionButton(
//                     icon: Icons.refresh,
//                     label: 'Refresh Data',
//                     subtitle: 'Update analytics with latest data',
//                     color: const Color(0xFF0F9D58),
//                     onTap: () {
//                       _loadData();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Data refreshed')),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 12),

//                   _buildActionButton(
//                     icon: Icons.view_list,
//                     label: 'View All Reports',
//                     subtitle: 'See detailed list of all reports',
//                     color: const Color(0xFF2E5C9A),
//                     onTap: () {
//                       // TODO: Navigate to full reports list
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Opening reports list...')),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 32),

//                   // Info Card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.blue.shade200,
//                         width: 1,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.info_outline,
//                           color: Colors.blue.shade700,
//                           size: 24,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'Analytics data is updated in real-time. Reports are automatically flagged for admin review when submitted by users.',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: Colors.blue.shade900,
//                               height: 1.4,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildSummaryRow({
//     required String label,
//     required String value,
//     required Color valueColor,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey.shade700,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: valueColor,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard({
//     required String title,
//     required String value,
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
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 24,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: Colors.grey.shade200,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: Colors.grey.shade400,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }