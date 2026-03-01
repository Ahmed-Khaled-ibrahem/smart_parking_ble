import 'package:smart_parking_ble/app/theme/transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const Color darkBackGround = Color(0xFF191919);
  static const Color lightBackGround = Color(0xFFEBEBEB);
  static const Color blue = Color(0xFF1087ea);
  static const Color orange = Color(0xFFFAA533);
  static const Color darkOrange = Color(0xFFEF7722);
  static const Color greenHover = Color(0xFF98B137);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF191919);
  static const Color gray = Color(0xFF808080);
  static const Color trueBlack = Color(0xFF000000);
  static const Color pink = Color(0xFF8900AA);
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightBackGround,

    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SlideTransitionBuilder(),
        TargetPlatform.iOS: SlideTransitionBuilder(),
      },
    ),

    primaryColor: AppColors.blue,
    primaryColorDark: AppColors.blue,
    primaryColorLight: AppColors.blue,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.white,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightBackGround,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedLabelStyle: TextStyle(color: Colors.blue),
      unselectedLabelStyle: TextStyle(color: Colors.grey),
      elevation: 0,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackGround,

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackGround,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: false,
      selectedLabelStyle: TextStyle(color: Colors.blue),
      unselectedLabelStyle: TextStyle(color: Colors.grey),
      elevation: 0,
    ),

    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SlideTransitionBuilder(),
        TargetPlatform.iOS: SlideTransitionBuilder(),
      },
    ),

    primaryColor: AppColors.darkBackGround,
    primaryColorDark: AppColors.darkBackGround,
    primaryColorLight: AppColors.darkBackGround,
  );
}