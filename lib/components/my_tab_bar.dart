import 'package:flutter/material.dart';

class MyTabBar extends StatelessWidget {
  final TabController tabController;
  const MyTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TabBar(
        controller: tabController,
        tabs: [
          //Profile Info Tab (1st tab)
          Tab(text: 'Profile Info'),

          //My Products (2nd tab)
          Tab(text: 'My Products'),

          //Reviews (3RD tab)
          Tab(text: 'Reviews'),
        ],
      ),
    );
  }
}
