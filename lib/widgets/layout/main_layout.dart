import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/screens/home_page.dart';
import 'package:segma/screens/segmented_objects_page.dart';
import 'package:segma/screens/settings_page.dart';
import 'package:segma/screens/logs_page.dart';
import 'package:segma/screens/about_page.dart';
import 'package:segma/widgets/modern_sidebar.dart';
import 'package:segma/widgets/common/toast_overlay.dart';
import 'package:segma/widgets/dialogs/importance_dialog.dart';
import 'package:segma/services/notification_service.dart';
import 'package:segma/models/notification_model.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    // Écouter les notifications critiques
    ref.listen<AppNotification?>(notificationServiceProvider, (previous, next) {
      if (next != null && next.type == NotificationType.critical) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ImportanceDialog(
            message: next.message,
            type: next.type,
          ),
        ).then((_) {
          // Une fois le dialogue fermé, on peut effacer la notification
          ref.read(notificationServiceProvider.notifier).dismiss();
        });
      }
    });

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                message: isCollapsed ? 'Développer' : 'Réduire',
                child: IconButton(
                  icon: Icon(isCollapsed ? Icons.menu : Icons.menu_open),
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
              const ModernSidebar(),
              Expanded(child: _buildPage(currentPage)),
            ],
          ),
        ),
        // Overlay de notifications (bulles)
        const ToastOverlay(),
      ],
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
