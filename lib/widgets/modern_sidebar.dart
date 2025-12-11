import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';

class ModernSidebar extends ConsumerWidget {
  const ModernSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(currentPageProvider);
    final isDarkTheme = ref.watch(themeNotifierProvider);
    final isCollapsed = ref.watch(sidebarCollapsedProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 80 : 280,
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
              // Header
              if (!isCollapsed)
                _buildExpandedHeader(context, ref)
              else
                _buildCollapsedHeader(context, ref),

              const Divider(height: 1),

              // Navigation items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCollapsed ? 4 : 12,
                    vertical: 16,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...NavigationPage.values.map((page) {
                      final isSelected = currentPage == page;
                      return isCollapsed
                          ? _buildCollapsedNavItem(
                              context,
                              page: page,
                              isSelected: isSelected,
                              onTap: () {
                                ref.read(currentPageProvider.notifier).state =
                                    page;
                              },
                            )
                          : _buildNavItem(
                              context,
                              page: page,
                              isSelected: isSelected,
                              onTap: () {
                                ref.read(currentPageProvider.notifier).state =
                                    page;
                              },
                            );
                    }),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Footer
              if (!isCollapsed)
                _buildExpandedFooter(context, ref)
              else
                _buildCollapsedFooter(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedHeader(BuildContext context, WidgetRef ref) {
    return Padding(
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildCollapsedHeader(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[400]!, Colors.blue[600]!],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.image_search, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCollapsedNavItem(
    BuildContext context, {
    required NavigationPage page,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final IconData icon = _getSelectedIcon(page);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tooltip(
        message: page.label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedFooter(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Theme toggle
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isDarkTheme ? 'Mode clair' : 'Mode sombre',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Version
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedFooter(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Tooltip(
        message: isDarkTheme ? 'Mode clair' : 'Mode sombre',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
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
