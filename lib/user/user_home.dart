import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/order_management/order_histroy_status.dart';
import 'package:pizza_delivery_app/user/cart_page.dart';
import 'package:pizza_delivery_app/user/menu_screen.dart';
import 'package:pizza_delivery_app/user/search.dart';
import 'package:pizza_delivery_app/user/account_info.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    MenuScreen(),
    SearchFilterScreen(),
    CartPage(),
    OrderHistoryPage(),
    AccountInfoPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(0),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: ColorApp.primary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'User',
            ),
          ],
        ),
      ),
    );
  }
}
