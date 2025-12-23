import 'package:flutter/material.dart';

class UserReviewsPage extends StatefulWidget {
  const UserReviewsPage({super.key});

  @override
  State<UserReviewsPage> createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  int selectedTabIndex = 2; // Reviews tab selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header Section with Blue Background
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF2196F3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              print('Back button pressed');
                            },
                          ),
                        ),
                        // Title
                        const Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48), // Spacer for alignment
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Profile Avatar and Info
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Text(
                      'JD',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'john_doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'John Doe',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Tab Bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _TabButton(
                  label: 'Profile Info',
                  isSelected: selectedTabIndex == 0,
                  onTap: () {
                    setState(() {
                      selectedTabIndex = 0;
                    });
                    print('Profile Info tab selected');
                  },
                ),
                _TabButton(
                  label: 'My Products',
                  isSelected: selectedTabIndex == 1,
                  onTap: () {
                    setState(() {
                      selectedTabIndex = 1;
                    });
                    print('My Products tab selected');
                  },
                ),
                _TabButton(
                  label: 'Reviews',
                  isSelected: selectedTabIndex == 2,
                  onTap: () {
                    setState(() {
                      selectedTabIndex = 2;
                    });
                    print('Reviews tab selected');
                  },
                ),
              ],
            ),
          ),
          // Content Section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Summary Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left side - Overall Rating
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    const Text(
                                      '4.5',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.star,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Based on 47 reviews',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Right side - Rating Bars
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: const [
                                    _RatingBar(stars: 5, count: 38, total: 47),
                                    SizedBox(height: 8),
                                    _RatingBar(stars: 4, count: 7, total: 47),
                                    SizedBox(height: 8),
                                    _RatingBar(stars: 3, count: 1, total: 47),
                                    SizedBox(height: 8),
                                    _RatingBar(stars: 2, count: 1, total: 47),
                                    SizedBox(height: 8),
                                    _RatingBar(stars: 1, count: 0, total: 47),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Comment TextField
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Add a comment',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Submit and Report Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    print('Submit pressed');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    print('Report pressed');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text(
                                    'Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Customer Reviews Title
                    const Text(
                      'Customer Reviews',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Review Cards
                    const _ReviewCard(
                      initials: 'SM',
                      name: 'Sarah M.',
                      timeAgo: '2 days ago',
                      review:
                          'Great seller! Item exactly as described and fast delivery.',
                    ),
                    const SizedBox(height: 12),
                    const _ReviewCard(
                      initials: 'AR',
                      name: 'Ahmad R.',
                      timeAgo: '1 week ago',
                      review:
                          'Good communication and fair pricing. Recommended!',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tab Button Widget
class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

// Rating Bar Widget
class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final int total;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = count / total;

    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // Background bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Filled bar
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 20,
          child: Text(
            '$count',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// Review Card Widget
class _ReviewCard extends StatelessWidget {
  final String initials;
  final String name;
  final String timeAgo;
  final String review;

  const _ReviewCard({
    required this.initials,
    required this.name,
    required this.timeAgo,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue[100],
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Review Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.black, size: 16),
                    Icon(Icons.star, color: Colors.black, size: 16),
                    Icon(Icons.star, color: Colors.black, size: 16),
                    Icon(Icons.star, color: Colors.black, size: 16),
                    Icon(Icons.star, color: Colors.black, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  review,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
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
