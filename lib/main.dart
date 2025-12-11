import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/config/app_theme.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/screens/home_page.dart';
import 'package:segma/screens/segmented_objects_page.dart';
import 'package:segma/screens/settings_page.dart';
import 'package:segma/screens/logs_page.dart';
import 'package:segma/screens/about_page.dart';
import 'package:segma/services/log_service.dart';
import 'package:segma/widgets/modern_sidebar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await logService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'SEGMA',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: const MainLayout(),
    );
  }
}

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final isVisible = ref.watch(sidebarVisibleProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: isVisible ? 'Masquer le menu' : 'Afficher le menu',
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                ref.read(sidebarVisibleProvider.notifier).state = !isVisible;
              },
            ),
          ),
        ),
        title: Text(
          currentPage.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Row(
        children: [
          // Sidebar de navigation moderne
          const ModernSidebar(),
          // Contenu principal
          Expanded(child: _buildPage(currentPage)),
        ],
      ),
    );
  }

  Widget _buildPage(NavigationPage page) {
    switch (page) {
      case NavigationPage.home:
        return const HomePage();
      case NavigationPage.segmented:
        return const SegmentedObjectsPage();
      case NavigationPage.settings:
        return const SettingsPage();
      case NavigationPage.logs:
        return const LogsPage();
      case NavigationPage.about:
        return const AboutPage();
    }
  }
}
