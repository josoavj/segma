import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/file_provider.dart';
import 'package:segma/services/folder_paths_service.dart';
import 'package:segma/services/file_service.dart';
import 'package:segma/widgets/folder_tree_widget.dart';
import 'package:segma/widgets/folder_picker_widget.dart';
import 'package:segma/widgets/image_grid_widget.dart';
import 'package:segma/widgets/image_viewer_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderStructureAsync = ref.watch(folderStructureProvider);
    final selectedFolder = ref.watch(selectedFolderProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    return Scaffold(
      body: folderStructureAsync.when(
        data: (folderStructure) {
          return Row(
            children: [
              // Colonne 1: Navigation des dossiers améliorée
              _buildSidebarPanel(context, ref, folderStructure, selectedFolder),

              // Colonne 2: Grille des images
              if (selectedFolder != null)
                Expanded(
                  child: Column(
                    children: [
                      _buildImageHeaderPanel(context, selectedFolder),
                      Expanded(
                        child: ImageGridWidget(
                          folderPath: selectedFolder.path,
                          onImageSelected: (image) {
                            // Naviguer vers ImageViewerScreen au lieu d'afficher dans la colonne
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImageViewerScreen(image: image),
                              ),
                            );
                          },
                          selectedImage: selectedImage,
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildEmptyState(context),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarPanel(
    BuildContext context,
    WidgetRef ref,
    folderStructure,
    selectedFolder,
  ) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // En-tête avec sélecteur de dossier
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder_special, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dossiers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFolderButtons(context, ref),
                const SizedBox(height: 12),
                _buildCustomFolderButton(context, ref),
              ],
            ),
          ),

          const Divider(height: 1),

          // Arborescence des dossiers
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FolderTreeWidget(
                  folder: folderStructure,
                  onFolderSelected: (folder) {
                    ref.read(selectedFolderProvider.notifier).state = folder;
                    ref.read(selectedImageProvider.notifier).state = null;
                  },
                  selectedFolder: selectedFolder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderButtons(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, String>>(
      future: FolderPathsService.getStandardFolders(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final folders = snapshot.data!;
        final customFolders = ref.watch(customFoldersProvider);

        return Column(
          children: [
            // Dossiers standards
            _buildFolderButton(
              context,
              ref,
              '📄 Documents',
              folders['documents']!,
            ),
            const SizedBox(height: 8),
            _buildFolderButton(context, ref, '🖼️ Images', folders['images']!),
            const SizedBox(height: 8),
            _buildFolderButton(
              context,
              ref,
              '⬇️ Téléchargements',
              folders['downloads']!,
            ),
            const SizedBox(height: 8),
            _buildFolderButton(context, ref, '🖥️ Bureau', folders['desktop']!),

            // Dossiers personnalisés avec animation
            if (customFolders.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 12),
            ],
            ...customFolders.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;
              final folderName = path.split('/').last;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                curve: Curves.easeInOut,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildCustomFolderDisplayButton(
                    context,
                    ref,
                    '📁 $folderName',
                    path,
                    onRemove: () {
                      ref.read(customFoldersProvider.notifier).state = [
                        ...customFolders.sublist(0, index),
                        ...customFolders.sublist(index + 1),
                      ];
                    },
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCustomFolderButton(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFolderPickerDialog(context, ref),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ajouter un dossier',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderPickerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un dossier'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: FolderPickerWidget(
            onFolderSelected: (path) async {
              // Charger directement le dossier sans changer selectedFolderPathProvider
              final folder = await FileService.loadFolderStructure(path);
              // Ajouter le nouveau dossier à la liste au lieu de le remplacer
              final customFolders = ref.read(customFoldersProvider);
              if (!customFolders.contains(path)) {
                ref.read(customFoldersProvider.notifier).state = [
                  ...customFolders,
                  path,
                ];
              }
              ref.read(selectedFolderProvider.notifier).state = folder;
              ref.read(selectedImageProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFolderDisplayButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    String path, {
    required VoidCallback onRemove,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Charger directement le dossier sans changer selectedFolderPathProvider
          final folder = await FileService.loadFolderStructure(path);
          ref.read(selectedFolderProvider.notifier).state = folder;
          ref.read(selectedImageProvider.notifier).state = null;
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDarkMode
                ? Colors.grey[800]?.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.bookmark_outlined,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 16, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    String path,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Charger directement le dossier sans changer selectedFolderPathProvider
          final folder = await FileService.loadFolderStructure(path);
          ref.read(selectedFolderProvider.notifier).state = folder;
          ref.read(selectedImageProvider.notifier).state = null;
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDarkMode
                ? Colors.grey[800]?.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeaderPanel(BuildContext context, selectedFolder) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.image_search,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Images du dossier',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  selectedFolder.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.grey[50],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.folder_open_outlined,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Aucun dossier sélectionné',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez un dossier dans\nla barre latérale pour afficher les images',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
