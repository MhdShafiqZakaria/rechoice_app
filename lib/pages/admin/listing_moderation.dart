import 'package:flutter/material.dart';
import 'package:rechoice_app/components/admin/admin_shared_widget.dart';
import 'package:rechoice_app/models/utils/export_utils.dart';

class ListingModerationPage extends StatefulWidget {
  const ListingModerationPage({super.key});

  @override
  State<ListingModerationPage> createState() => _ListingModerationPageState();
}

class _ListingModerationPageState extends State<ListingModerationPage> {
  int selectedTabIndex = 2; // Listing Moderation tab selected
  String selectedStatus = 'All Status';
  String searchQuery = '';
  List<Map<String, dynamic>> filteredListings = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadMockListings();
    });
  }

  void _loadMockListings() {
    // TODO: Load actual listings from Firestore
    // For now using mock data
    filteredListings = [
      {
        'id': 'LIST001',
        'title': 'iPhone 14 Pro',
        'category': 'Electronics',
        'price': 999.99,
        'status': 'Approved',
        'sellerName': 'John Doe',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        'views': 245,
        'description': 'Excellent condition iPhone 14 Pro',
      },
      {
        'id': 'LIST002',
        'title': 'Winter Jacket',
        'category': 'Fashion',
        'price': 89.99,
        'status': 'Pending',
        'sellerName': 'Jane Smith',
        'createdAt': DateTime.now().subtract(const Duration(days: 2)),
        'views': 120,
        'description': 'New winter jacket, size M',
      },
      {
        'id': 'LIST003',
        'title': 'Coffee Table',
        'category': 'Home & Living',
        'price': 149.99,
        'status': 'Flagged',
        'sellerName': 'Mike Johnson',
        'createdAt': DateTime.now(),
        'views': 45,
        'description': 'Wooden coffee table in good condition',
      },
    ];
  }

  Future<void> _exportListings() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exporting listings...'),
          duration: Duration(seconds: 2),
        ),
      );

      final filePath = await ExportUtils.exportListingsToCSV(filteredListings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Listings exported successfully to ${filePath.split('/').last}',
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export failed: ${e.toString()}'),
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
      selectedTabIndex: 2,
      title: 'Listing Moderation',
      subtitle: 'Review and moderate user listings',

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Content Section
              // Search Bar and Filter
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search listings...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
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
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                          value: 'All Status',
                          child: Text('All Status'),
                        ),
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Approved',
                          child: Text('Approved'),
                        ),
                        DropdownMenuItem(
                          value: 'Flagged',
                          child: Text('Flagged'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                        print('Status filter: $value');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Export Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    _exportListings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Export Listings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'LISTING',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'STATUS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'ACTIONS',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Listing Rows
              const _ListingRow(
                title: 'iPhone 15 Pro Max',
                postedDate: 'Posted on 2024-03-10',
                price: 'RM1299',
                status: 'pending',
              ),
              const _ListingRow(
                title: 'MacBook Air M2',
                postedDate: 'Posted on 2024-03-08',
                price: 'RM4999',
                status: 'approved',
              ),
              const _ListingRow(
                title: 'Samsung Galaxy S24',
                postedDate: 'Posted on 2024-03-09',
                price: 'RM3299',
                status: 'flagged',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Listing Row Widget
class _ListingRow extends StatelessWidget {
  final String title;
  final String postedDate;
  final String price;
  final String status;

  const _ListingRow({
    required this.title,
    required this.postedDate,
    required this.price,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'flagged':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  postedDate,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
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
                  status,
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
                InkWell(
                  onTap: () {
                    print('View $title');
                  },
                  child: const Text(
                    'View',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    print('Approve $title');
                  },
                  child: const Text(
                    'Approve',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    print('Reject $title');
                  },
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
