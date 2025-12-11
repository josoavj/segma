import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';

class ModernSidebar extends ConsumerWidget {
  const ModernSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final isVisible = ref.watch(sidebarVisibleProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isVisible ? 280 : 0,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            border: Border(
              right: BorderSide(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header avec logo/titre
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image_search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'SEGMA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Image Segmentation',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Navigation items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...NavigationPage.values.map((page) {
                        final isSelected = currentPage == page;
                        return _buildNavItem(
                          context,
                          page: page,
                          isSelected: isSelected,
                          onTap: () {
                            ref.read(currentPageProvider.notifier).state = page;
                          },
                        );
                      }),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Footer avec options
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Theme toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Icon(
                            isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                            size: 20,
                          ),
                          title: Text(
                            isDarkTheme ? 'Mode clair' : 'Mode sombre',
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () {
                            ref
                                .read(themeNotifierProvider.notifier)
                                .toggleTheme();
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Version
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required NavigationPage page,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: ListTile(
          leading: Icon(
            isSelected ? _getSelectedIcon(page) : _getUnselectedIcon(page),
            color: isSelected ? Colors.blue : Colors.grey,
            size: 20,
          ),
          title: Text(
            page.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.blue : null,
            ),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
        ),
      ),
    );
  }

  IconData _getSelectedIcon(NavigationPage page) {
    switch (page) {
      case NavigationPage.home:
        return Icons.home;
      case NavigationPage.segmented:
        return Icons.layers;
      case NavigationPage.settings:
        return Icons.settings;
      case NavigationPage.logs:
        return Icons.history;
      case NavigationPage.about:
        return Icons.info;
    }
  }

  IconData _getUnselectedIcon(NavigationPage page) {
    switch (page) {
      case NavigationPage.home:
        return Icons.home_outlined;
      case NavigationPage.segmented:
        return Icons.layers_outlined;
      case NavigationPage.settings:
        return Icons.settings_outlined;
      case NavigationPage.logs:
        return Icons.history_outlined;
      case NavigationPage.about:
        return Icons.info_outlined;
    }
  }
}
