import 'package:flutter/material.dart';
import 'package:rechoice_app/pages/main-dashboard/catalog.dart';
import 'package:rechoice_app/pages/main-dashboard/dashboard.dart';
import 'package:rechoice_app/pages/payment/cart.dart';
import 'package:rechoice_app/pages/users/user_profile_info.dart';


class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  int _selectedIndex = 0;

  final List <Widget> _pages = [
    Dashboard(),
    CatalogsPage(),
    CartPage(),
    UserProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:IndexedStack(index: _selectedIndex,children: _pages),

    // ================== BOTTOM NAVIGATION BAR ==================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!, Colors.blue[500]!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 16.0,
          unselectedFontSize: 14.0,
          iconSize: 28.0,
          currentIndex: _selectedIndex,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          onTap: (index){
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),);
  }
}