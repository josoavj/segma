import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/screens/home_page.dart';
import 'package:segma/screens/segmented_objects_page.dart';
import 'package:segma/screens/settings_page.dart';
import 'package:segma/screens/logs_page.dart';
import 'package:segma/screens/about_page.dart';
import 'package:segma/services/log_service.dart';
import 'package:segma/widgets/modern_sidebar.dart';
import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation des services
  await logService.initialize();
  
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

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
      builder: (context, child) {
        return AppBackground(child: child);
      },
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget? child;
  const AppBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF0A1024),
                        Color(0xFF151D38),
                        Color(0xFF102A43),
                      ]
                    : const [
                        Color(0xFFEFF5FF),
                        Color(0xFFE6F9FF),
                        Color(0xFFF7F4FF),
                      ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -80,
          child: RepaintBoundary(
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF6CA8FF).withValues(alpha: 0.18)
                    : const Color(0xFF66C5FF).withValues(alpha: 0.22),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          right: -120,
          child: RepaintBoundary(
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF7D8BFF).withValues(alpha: 0.16)
                    : const Color(0xFF9DE7FF).withValues(alpha: 0.26),
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Tooltip(
            message: isCollapsed ? 'Développer' : 'Réduire',
            child: IconButton(
              icon: Icon(isCollapsed ? Icons.unfold_more : Icons.unfold_less),
              onPressed: () {
                ref.read(sidebarCollapsedProvider.notifier).state =
                    !isCollapsed;
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
