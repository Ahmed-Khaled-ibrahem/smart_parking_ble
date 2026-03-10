import 'package:smart_parking_ble/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_parking_ble/screens/home/home_screen.dart';
import 'package:toastification/toastification.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/current_parking/current_parking_details.dart';
import '../screens/find_parking/find_parking.dart';
import '../screens/find_parking/navigate_to_parking.dart';
import '../screens/history/parking_history.dart';
import '../screens/login/view/login_screen.dart';
import '../screens/login/view/register_screen.dart';
import '../screens/login/view/wlecome_screen.dart';
import '../screens/parking_area/view/parking_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToastificationWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MAWQIFI',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/find': (context) => const AvailableParkingScreen(),
          '/navigate': (context) => const ParkingNavigationScreen(),
          '/history': (context) => const ParkingHistoryScreen(),
          '/current': (context) => const CurrentParkingScreen(),
          '/navigate_back': (context) => const ParkingScreen(),
          '/admin': (context) => const AdminScreen(),
        },
      ),
    );
  }
}
