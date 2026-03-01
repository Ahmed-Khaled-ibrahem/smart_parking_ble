import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/view/client_home_screen.dart';

class ClientNavigation extends ConsumerStatefulWidget {
  const ClientNavigation({super.key});
  @override
  ClientHomeState createState() => ClientHomeState();
}

class ClientHomeState extends ConsumerState<ClientNavigation> {
  int currentIndex = 0;

  final screens = [
    const ClientHomeScreen(),
    const ClientHomeScreen(),
    const ClientHomeScreen(),
    const ClientHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              iconPath: 'assets/icons/chat.png',
              height: height,
              isDark: isDark,
              isActive: false,
            ),
            activeIcon: iconItem(
              iconPath: 'assets/icons/chat.png',
              height: height,
              isDark: isDark,
              isActive: true,
            ),
            label: "Chat",
            tooltip: "Chat",
          ),
          BottomNavigationBarItem(
            icon: iconItem(
              iconPath: 'assets/icons/search.png',
              height: height,
              isDark: isDark,
              isActive: false,
            ),
            activeIcon: iconItem(
              iconPath: 'assets/icons/search.png',
              height: height,
              isDark: isDark,
              isActive: true,
            ),
            label: "Find",
            tooltip: "Find",
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
