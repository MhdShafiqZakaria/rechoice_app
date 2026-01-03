// admin_shared_widget.dart
import 'package:flutter/material.dart';
import 'package:rechoice_app/components/user/sliver_tab_bar_delegate.dart';
import 'package:rechoice_app/models/services/authenticate.dart';

class AdminSliverScaffold extends StatefulWidget {
  final int selectedTabIndex;
  final Widget body;
  final String title;
  final String subtitle;

  const AdminSliverScaffold({
    super.key,
    required this.selectedTabIndex,
    required this.body,
    required this.title,
    required this.subtitle,
  });

  @override
  State<AdminSliverScaffold> createState() => _AdminSliverScaffoldState();
}

class _AdminSliverScaffoldState extends State<AdminSliverScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.selectedTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
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
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.people,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text(
                                    'Admin Dashboard',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await authService.value.logout();
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/',
                                        (route) => false,
                                      );
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard)),
                    Tab(icon: Icon(Icons.person)),
                    Tab(icon: Icon(Icons.folder)),
                    Tab(icon: Icon(Icons.access_time)),
                  ],
                  indicatorColor: Colors.blue,
                  indicatorWeight: 3,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey[600],
                  onTap: (index) {
                    if (index == widget.selectedTabIndex) return;

                    final routes = [
                      '/adminDashboard',
                      '/manageUser',
                      '/listingMod',
                      '/report',
                    ];
                    Navigator.pushReplacementNamed(context, routes[index]);
                  },
                ),
              ),
            ),
          ];
        },
        body: widget.body,
      ),
    );
  }
}
