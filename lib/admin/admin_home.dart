import 'package:flutter/material.dart';
import 'package:pizza_delivery_app/admin/add_pizza.dart';
import 'package:pizza_delivery_app/admin/revenue_page.dart';
import 'package:pizza_delivery_app/admin/view_pizza.dart';
import 'package:pizza_delivery_app/core/color_app.dart';
import 'package:pizza_delivery_app/order_management/order_approve.dart';
import 'package:pizza_delivery_app/user/account_info.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AddPizzaPage(),
    ViewPizzaPage(),
    OrderManagerPage(),
    RevenueDashboard(),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange[300],
        unselectedItemColor: Colors.grey[400],
        backgroundColor: ColorApp.primary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pizza_rounded),
            label: 'Tạo pizza',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Cửa hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task_sharp),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.toc),
            label: 'Doanh thu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
