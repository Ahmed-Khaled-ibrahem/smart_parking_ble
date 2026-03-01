import 'package:smart_parking_ble/features/profile/view/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/view/admin_home.dart';

class AdminNavigation extends ConsumerStatefulWidget {
  const AdminNavigation({super.key});
  @override
  AdminNavigationState createState() => AdminNavigationState();
}

class AdminNavigationState extends ConsumerState<AdminNavigation> {
  int currentIndex = 0;

  final screens = [
    const AdminHome(),
    const ProfileScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isDark =  Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        iconSize: height * 0.04,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: iconItem(
              iconPath: 'assets/icons/home.png',
              height: height,
              isDark: isDark,
              isActive: false,
            ),
            activeIcon: iconItem(
              iconPath: 'assets/icons/home.png',
              height: height,
              isDark: isDark,
              isActive: true,
            ),
            label: "Home",
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: iconItem(
              iconPath: 'assets/icons/help-center.png',
              height: height,
              isDark: isDark,
              isActive: false,
            ),
            activeIcon: iconItem(
              iconPath: 'assets/icons/help-center.png',
              height: height,
              isDark: isDark,
              isActive: true,
            ),
            label: "Chat",
            tooltip: "Chat",
          ),
          BottomNavigationBarItem(
            icon: iconItem(
              iconPath: 'assets/icons/profile.png',
              height: height,
              isDark: isDark,
              isActive: false,
            ),
            activeIcon: iconItem(
              iconPath: 'assets/icons/profile.png',
              height: height,
              isDark: isDark,
              isActive: true,
            ),
            label: "Account",
            tooltip: "Account",
          ),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: screens),
    );
  }

  Widget iconItem({
    required String iconPath,
    required double height,
    required bool isDark,
    required bool isActive,
  }) {
    return Image.asset(
      iconPath,
      height: height * 0.04,
      color: isActive ? Colors.blue : isDark ? Colors.white : Colors.black,
    );
  }
}

