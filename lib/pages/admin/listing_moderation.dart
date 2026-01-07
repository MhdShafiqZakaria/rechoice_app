import 'package:flutter/material.dart';
import 'package:rechoice_app/components/admin/admin_shared_widget.dart';
import 'package:rechoice_app/models/services/firestore_service.dart';
import 'package:rechoice_app/models/services/item_service.dart';
import 'package:rechoice_app/models/services/listing_service.dart';
import 'package:rechoice_app/models/services/local_storage_service.dart';
import 'package:rechoice_app/models/services/unified_listing_service.dart';
import 'package:rechoice_app/models/utils/export_utils.dart';
import 'package:rechoice_app/models/services/listing_moderation_service.dart';

class ListingModerationPage extends StatefulWidget {
  const ListingModerationPage({super.key});

  @override
  State<ListingModerationPage> createState() => _ListingModerationPageState();
}

class _ListingModerationPageState extends State<ListingModerationPage> {
  late UnifiedListingService _service;
  int selectedTabIndex = 2; // Listing Moderation tab selected
  String selectedStatus = 'All Status';
  String searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final firestoreService = FirestoreService();
    final itemService = ItemService(firestoreService, LocalStorageService());
    final listingService = ListingService(firestoreService, itemService);
    final moderationService = ListingModerationService();
    _service = UnifiedListingService(listingService, moderationService);
  }

  /// Fetch filtered listings from Firestore
  Future<List<Map<String, dynamic>>> _getFilteredListings() async {
    try {
      // Convert UI status to Firestore status
      String? statusFilter;
      if (selectedStatus != 'All Status') {
        statusFilter = selectedStatus.toLowerCase();
      }

      // If search query is empty, just get by status
      if (searchQuery.isEmpty) {
        return await _service.getModerationListings(statusFilter: statusFilter);
      }

      // Otherwise, search with status filter
      return await _service.searchModerationListings(
        searchQuery,
        statusFilter: statusFilter,
      );
    } catch (e) {
      print('❌ Error loading listings: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error loading listings: $e')));
      }
      return [];
    }
  }

  Future<void> _exportListings() async {
    try {
      setState(() => _isLoading = true);

      // Get current filtered listings
      final listings = await _getFilteredListings();

      if (listings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No listings to export. Please adjust your filters.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exporting listings...'),
          duration: Duration(seconds: 2),
        ),
      );

      final filePath = await ExportUtils.exportListingsToCSV(listings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Exported ${listings.length} listings successfully to ${filePath.split('/').last}',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveListingAsync(String listingId) async {
    try {
      setState(() => _isLoading = true);
      await _service.approveListing(listingId);
      if (mounted) {
        setState(() {}); // Trigger rebuild to refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Listing approved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Failed to approve: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectListingAsync(String listingId) async {
    try {
      setState(() => _isLoading = true);
      await _service.rejectListing(listingId);
      if (mounted) {
        setState(() {}); // Trigger rebuild to refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Listing rejected'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Failed to reject: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _flagListingAsync(String listingId) async {
    try {
      setState(() => _isLoading = true);
      await _service.flagListing(
        listingId,
        reason: 'Flagged by moderator',
      );
      if (mounted) {
        setState(() {}); // Trigger rebuild to refresh list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Listing flagged'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Failed to flag: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _viewListing(Map<String, dynamic> listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text((listing['title'] ?? 'Listing Details').toString()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Seller',
                _safeString(listing['sellerName'], 'Unknown'),
              ),
              _buildDetailRow(
                'Price',
                'RM${_safeString(listing['price'], 'N/A')}',
              ),
              _buildDetailRow(
                'Category',
                _safeString(listing['category'], 'N/A'),
              ),
              _buildDetailRow(
                'Status',
                _safeString(listing['status'], 'Unknown'),
              ),
              _buildDetailRow('Views', _safeString(listing['views'], '0')),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                _safeString(listing['description'], 'No description'),
                style: const TextStyle(fontSize: 12),
              ),
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

  String _safeString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(value, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminSliverScaffold(
      selectedTabIndex: 2,
      title: 'Listing Moderation',
      subtitle: 'Review and manage user listings',
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by title, description, or seller...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Status Filter and Export Button
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        items:
                            [
                                  'All Status',
                                  'Pending',
                                  'Approved',
                                  'Rejected',
                                  'Flagged',
                                ]
                                .map(
                                  (status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _exportListings,
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Listings List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getFilteredListings(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final listings = snapshot.data ?? [];

                // Empty state
                if (listings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox_outlined, size: 48),
                        const SizedBox(height: 16),
                        const Text('No listings found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                              selectedStatus = 'All Status';
                            });
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                // List of listings
                return Stack(
                  children: [
                    ListView.builder(
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return _ListingRow(
                          listing: listing,
                          onView: () => _viewListing(listing),
                          onApprove: () => _approveListingAsync(listing['id']),
                          onReject: () => _rejectListingAsync(listing['id']),
                          onFlag: () => _flagListingAsync(listing['id']),
                        );
                      },
                    ),
                    // Loading overlay
                    if (_isLoading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Listing Row Widget
class _ListingRow extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onView;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onFlag;

  const _ListingRow({
    required this.listing,
    required this.onView,
    required this.onApprove,
    required this.onReject,
    required this.onFlag,
  });

  Color _getStatusColor() {
    final status = (listing['moderationStatus'] ?? '').toString().toLowerCase();
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'flagged':
        return Colors.red;
      case 'rejected':
        return Colors.red[800] ?? Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = listing['price'] ?? 0;
    final priceStr = price is int
        ? 'RM$price'
        : 'RM${price.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Listing Info
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing['title'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Seller: ${listing['sellerName'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  priceStr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Category: ${listing['category'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (listing['moderationStatus'] ?? 'pending')
                      .toString()
                      .toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ActionLink(label: 'View', color: Colors.blue, onTap: onView),
                const SizedBox(height: 4),
                _ActionLink(
                  label: 'Approve',
                  color: Colors.green,
                  onTap: onApprove,
                ),
                const SizedBox(height: 4),
                _ActionLink(
                  label: 'Reject',
                  color: Colors.red,
                  onTap: onReject,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable action link widget
class _ActionLink extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionLink({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
