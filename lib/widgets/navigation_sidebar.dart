import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';

class NavigationSidebar extends ConsumerWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return NavigationRail(
      selectedIndex: currentPage.index,
      onDestinationSelected: (index) {
        ref.read(currentPageProvider.notifier).state =
            NavigationPage.values[index];
      },
      labelType: NavigationRailLabelType.selected,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(NavigationPage.home.label),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.layers_outlined),
          selectedIcon: const Icon(Icons.layers),
          label: Text(NavigationPage.segmented.label),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: Text(NavigationPage.settings.label),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: const Icon(Icons.history),
          label: Text(NavigationPage.logs.label),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.info_outlined),
          selectedIcon: const Icon(Icons.info),
          label: Text(NavigationPage.about.label),
        ),
      ],
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: isDarkTheme ? 'Mode clair' : 'Mode sombre',
              child: IconButton(
                icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  ref.read(themeNotifierProvider.notifier).toggleTheme();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
