import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(elevation: 2, centerTitle: true),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.grey[100],
        selectedIconTheme: const IconThemeData(color: Colors.blue, size: 28),
        unselectedIconTheme: IconThemeData(color: Colors.grey[600], size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(elevation: 2, centerTitle: true),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.grey[900],
        selectedIconTheme: const IconThemeData(color: Colors.blue, size: 28),
        unselectedIconTheme: IconThemeData(color: Colors.grey[500], size: 24),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }
}
