// // screens/admin/listing_moderation.dart
// import 'package:flutter/material.dart';
// import 'package:test_project/models/item.dart';
// import 'package:test_project/services/admin_dummy_data.dart';

// class ListingModerationScreen extends StatefulWidget {
//   const ListingModerationScreen({Key? key}) : super(key: key);

//   @override
//   State<ListingModerationScreen> createState() => _ListingModerationScreenState();
// }

// class _ListingModerationScreenState extends State<ListingModerationScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Item> _allListings = [];
//   List<Item> _filteredListings = [];
//   String _selectedFilter = 'All Status';

//   @override
//   void initState() {
//     super.initState();
//     _loadListings();
//   }

//   void _loadListings() {
//     setState(() {
//       _allListings = AdminDummyDataService.getItemsForModeration();
//       _filteredListings = _allListings;
//     });
//   }

//   void _searchListings(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _filteredListings = _allListings;
//       } else {
//         _filteredListings = AdminDummyDataService.searchItems(query);
//       }
//       _applyStatusFilter();
//     });
//   }

//   void _applyStatusFilter() {
//     if (_selectedFilter == 'All Status') {
//       return;
//     }
    
//     setState(() {
//       switch (_selectedFilter) {
//         case 'Pending':
//           _filteredListings = _filteredListings.where((i) => i.isPending).toList();
//           break;
//         case 'Approved':
//           _filteredListings = _filteredListings.where((i) => i.isApproved).toList();
//           break;
//         case 'Rejected':
//           _filteredListings = _filteredListings.where((i) => i.isRejected).toList();
//           break;
//         case 'Flagged':
//           _filteredListings = _filteredListings.where((i) => i.isFlagged).toList();
//           break;
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
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildFilterOption('All Status'),
//               _buildFilterOption('Pending'),
//               _buildFilterOption('Approved'),
//               _buildFilterOption('Rejected'),
//               _buildFilterOption('Flagged'),
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
//           _searchListings(_searchController.text);
//         });
//         Navigator.pop(context);
//       },
//     );
//   }

//   void _viewListing(Item item) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(item.title),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildInfoRow('Brand', item.brand),
//                 _buildInfoRow('Category', item.category.name),
//                 _buildInfoRow('Condition', item.condition),
//                 _buildInfoRow('Price', item.formattedPrice),
//                 _buildInfoRow('Quantity', item.quantity.toString()),
//                 _buildInfoRow('Status', item.moderationStatusText),
//                 _buildInfoRow('Posted Date', item.formattedPostedDate),
//                 _buildInfoRow('Seller ID', item.sellerID.toString()),
//                 if (item.rejectionReason != null)
//                   _buildInfoRow('Rejection Reason', item.rejectionReason!),
//                 if (item.moderatedDate != null)
//                   _buildInfoRow('Moderated Date', item.formattedModeratedDate),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Description:',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(item.description),
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
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _approveListing(Item item) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Approve Listing'),
//           content: Text('Are you sure you want to approve "${item.title}"?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0F9D58),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//                 // TODO: Update item status in Firebase
//                 // item.approve(adminID)
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('"${item.title}" has been approved')),
//                 );
//                 _loadListings();
//               },
//               child: const Text('Approve'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _rejectListing(Item item) {
//     final TextEditingController reasonController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Reject Listing'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Rejecting "${item.title}"'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: reasonController,
//                 decoration: const InputDecoration(
//                   labelText: 'Rejection Reason',
//                   hintText: 'Enter reason for rejection',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
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
//                 if (reasonController.text.trim().isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please provide a reason')),
//                   );
//                   return;
//                 }
//                 Navigator.pop(context);
//                 // TODO: Update item status in Firebase
//                 // item.reject(adminID, reasonController.text)
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('"${item.title}" has been rejected')),
//                 );
//                 _loadListings();
//               },
//               child: const Text('Reject'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _flagListing(Item item) {
//     final TextEditingController reasonController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Flag Listing'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Flagging "${item.title}" for review'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: reasonController,
//                 decoration: const InputDecoration(
//                   labelText: 'Flag Reason',
//                   hintText: 'Enter reason for flagging',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFF4B400),
//               ),
//               onPressed: () {
//                 if (reasonController.text.trim().isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please provide a reason')),
//                   );
//                   return;
//                 }
//                 Navigator.pop(context);
//                 // TODO: Update item status in Firebase
//                 // item.flag(adminID, reasonController.text)
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('"${item.title}" has been flagged')),
//                 );
//                 _loadListings();
//               },
//               child: const Text('Flag'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _exportListings() {
//     // TODO: Implement export functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Exporting listings...')),
//     );
//   }

//   Color _getStatusColor(Item item) {
//     switch (item.moderationStatusColor) {
//       case 'orange':
//         return const Color(0xFFF4B400);
//       case 'green':
//         return const Color(0xFF0F9D58);
//       case 'red':
//         return const Color(0xFFDB4437);
//       default:
//         return Colors.grey;
//     }
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
//           'Listing Moderation',
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
//                   'Listing Moderation',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Review and moderate user listings',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Search Bar
//                 TextField(
//                   controller: _searchController,
//                   onChanged: _searchListings,
//                   decoration: InputDecoration(
//                     hintText: 'Search listings...',
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: _searchController.text.isNotEmpty
//                         ? IconButton(
//                             icon: const Icon(Icons.clear),
//                             onPressed: () {
//                               _searchController.clear();
//                               _searchListings('');
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
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 // Export Listings Button (Full Width)
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _exportListings,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4285F4),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Export Listings',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
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
//                   flex: 4,
//                   child: Text(
//                     'LISTING',
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
//                 Expanded(
//                   flex: 3,
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

//           // Listings List
//           Expanded(
//             child: _filteredListings.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.inventory_2_outlined,
//                           size: 80,
//                           color: Colors.grey.shade300,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No listings found',
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
//                     itemCount: _filteredListings.length,
//                     separatorBuilder: (context, index) => Divider(
//                       height: 1,
//                       color: Colors.grey.shade200,
//                     ),
//                     itemBuilder: (context, index) {
//                       final item = _filteredListings[index];
//                       return _buildListingRow(item);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildListingRow(Item item) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Row(
//         children: [
//           // Listing Info
//           Expanded(
//             flex: 4,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Posted on ${item.formattedPostedDate}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   item.formattedPrice,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2E5C9A),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Status Badge
//           Expanded(
//             flex: 2,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: _getStatusColor(item).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 item.moderationStatusText,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                   color: _getStatusColor(item),
//                 ),
//               ),
//             ),
//           ),

//           // Actions
//           Expanded(
//             flex: 3,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: () => _viewListing(item),
//                   child: const Text(
//                     'View',
//                     style: TextStyle(
//                       color: Color(0xFF4285F4),
//                       fontWeight: FontWeight.w600,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'approve') {
//                       _approveListing(item);
//                     } else if (value == 'reject') {
//                       _rejectListing(item);
//                     } else if (value == 'flag') {
//                       _flagListing(item);
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     if (!item.isApproved)
//                       const PopupMenuItem(
//                         value: 'approve',
//                         child: Text('Approve', style: TextStyle(color: Color(0xFF0F9D58))),
//                       ),
//                     if (!item.isRejected)
//                       const PopupMenuItem(
//                         value: 'reject',
//                         child: Text('Reject', style: TextStyle(color: Color(0xFFDB4437))),
//                       ),
//                     if (!item.isFlagged)
//                       const PopupMenuItem(
//                         value: 'flag',
//                         child: Text('Flag', style: TextStyle(color: Color(0xFFF4B400))),
//                       ),
//                   ],
//                   icon: const Icon(Icons.more_vert, size: 20),
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