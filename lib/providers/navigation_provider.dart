import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  ThemeNotifier() : super(false);

  void toggleTheme() {
    state = !state;
  }

  void setTheme(bool isDark) {
    state = isDark;
  }
}
