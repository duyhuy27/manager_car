import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:manager_car/screen/history_screen.dart';
import 'package:manager_car/screen/manager_car/manager_screen.dart';
import 'package:manager_car/screen/static_screen.dart';

import '../Home/home_screen.dart';

class GNavBar extends StatefulWidget {
  const GNavBar({super.key});

  @override
  State<GNavBar> createState() => _GNavBarState();
}

class _GNavBarState extends State<GNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ManagerScreen(),
    const HistoryScreen(),
    const StaticScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: GNav(
          gap: 8,
          rippleColor: Colors.grey,
          // tab button ripple color when pressed
          hoverColor: Colors.grey,
          backgroundColor: Colors.black,
          haptic: true,
          // haptic feedback
          tabBorderRadius: 15,
          duration: const Duration(milliseconds: 500),
          activeColor: Colors.white,
          color: Colors.grey,
          padding: const EdgeInsets.all(20),
          selectedIndex: _selectedIndex,
          onTabChange: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          tabs: const [
            GButton(
              icon: Icons.car_rental_outlined,
              text: 'Trang chủ',
            ),
            GButton(
              icon: Icons.edit_calendar_rounded,
              text: 'Quản lý',
            ),
            GButton(
              icon: Icons.history,
              text: 'Lịch sử',
            ),
            GButton(
              icon: Icons.currency_exchange_outlined,
              text: 'Doanh thu',
            )
          ]),
    );
  }
}
