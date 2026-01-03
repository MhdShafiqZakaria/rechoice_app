import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rechoice_app/components/user/edit_profile_dialog.dart';
import 'package:rechoice_app/components/user/my_products_tab.dart';
import 'package:rechoice_app/components/user/profile_app_bar.dart';
import 'package:rechoice_app/components/user/profile_info_tab.dart';
import 'package:rechoice_app/components/user/reviews_tab.dart';
import 'package:rechoice_app/components/user/sliver_tab_bar_delegate.dart';
import 'package:rechoice_app/models/model/users_model.dart';
import 'package:rechoice_app/models/services/authenticate.dart';
import 'package:rechoice_app/models/viewmodels/items_view_model.dart';
import 'package:rechoice_app/models/viewmodels/users_view_model.dart';

class UserProfile extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final String? uid;

  const UserProfile({super.key, this.uid, this.onBackPressed});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasLoadedItems = false;
  bool _isLoading = true;
  bool _dataLoaded = false;
  Users? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Delay to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {


    print('DEBUG: Starting _loadUserData');
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      print('DEBUG: Set loading state');

      final authUid = authService.value.currentUser?.uid;
      print('DEBUG: authUid = $authUid');

      if (authUid == null) {
        print('DEBUG: No authUid, setting error');
        setState(() {
          _error = 'Not authenticated';
          _isLoading = false;
        });
        return;
      }

      final profileUid = widget.uid ?? authUid;
      print('DEBUG: profileUid = $profileUid');

      final usersVM = context.read<UsersViewModel>();
      final itemsVM = context.read<ItemsViewModel>();
      print('DEBUG: Got ViewModels');

      // Check cache first
      Users? user = usersVM.getUserByUid(profileUid);
      print('DEBUG: User from cache = ${user != null}');

      // If not in cache, fetch from Firestore
      if (user == null) {
        print('DEBUG: Fetching user from Firestore...');
        user = await usersVM.fetchUserByUid(profileUid);
        print('DEBUG: Fetched user = ${user != null}');
      }

      if (user == null) {
        print('DEBUG: User not found, setting error');
        setState(() {
          _error = 'User not found in database';
          _isLoading = false;
        });
        return;
      }

      // Load user items
      if (!_hasLoadedItems) {
        print('DEBUG: Fetching user items...');
        _hasLoadedItems = true;
        await itemsVM
            .fetchUserItems(user.userID)
            .timeout(
              Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Item Fetch timed out');
              },
            );
        print('DEBUG: Fetched user items');
      }

      print('DEBUG: All data loaded, setting state');
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Exception in _loadUserData: $e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load profile: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logging out', textAlign: TextAlign.center),
        contentPadding: const EdgeInsets.all(20),
        content: const Text('Do you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.value.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    final authUid = authService.value.currentUser?.uid;
    if (authUid == null) return;

    // Get the latest user data from the ViewModel
    final user = context.read<UsersViewModel>().getUserByUid(authUid);

    if (user != null) {
      showDialog(
        context: context,
        builder: (context) => EditProfileDialog(user: user),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsVM = context.watch<ItemsViewModel>();
    final authUid = authService.value.currentUser?.uid;

    if (authUid == null) {
      return const Scaffold(body: Center(child: Text('Not Authenticated')));
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E5C9A),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: const CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E5C9A),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserData,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E5C9A),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E5C9A),
          title: const Text('Profile', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text('User not found')),
      );
    }
    final profileUid = widget.uid ?? authUid;
    final isOwnProfile = profileUid == authUid;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          ProfileAppBar(
            user: _user!,
            isOwnProfile: isOwnProfile,
            onEditPressed: _editProfile,
            onLogoutPressed: _logout,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2E5C9A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF2E5C9A),
                tabs: const [
                  Tab(text: 'Profile Info'),
                  Tab(text: 'My Products'),
                  Tab(text: 'Reviews'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                ProfileInfoTab(user: _user!, isOwnProfile: isOwnProfile),
                MyProductsTab(
                  itemsVM: itemsVM,
                  isOwnProfile: isOwnProfile,
                  user: _user!,
                ),
                ReviewsTab(user: _user!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
