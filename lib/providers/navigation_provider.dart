import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NavigationPage {
  home('Accueil', 'home'),
  segmented('Objets Segmentés', 'layers'),
  settings('Paramètres', 'settings'),
  logs('Logs', 'history'),
  about('À Propos', 'info');

  final String label;
  final String icon;

  const NavigationPage(this.label, this.icon);
}

final currentPageProvider = StateProvider<NavigationPage>((ref) {
  return NavigationPage.home;
});

final sidebarVisibleProvider = StateProvider<bool>((ref) {
  return true;
});

final sidebarCollapsedProvider = StateProvider<bool>((ref) {
  return false;
});

final isDarkThemeProvider = StateProvider<bool>((ref) {
  return false;
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool('darkTheme') ?? false;
    } catch (e) {
      state = false;
    }
  }

  void toggleTheme() {
    setTheme(!state);
  }

  Future<void> setTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkTheme', isDark);
      state = isDark;
    } catch (e) {
      state = isDark;
    }
  }
}
