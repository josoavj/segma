import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/file_provider.dart';
import 'package:segma/widgets/folder_tree_widget.dart';
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
      appBar: AppBar(
        title: const Text('SEGMA - Image Segmentation'),
        backgroundColor: Colors.blue,
      ),
      body: folderStructureAsync.when(
        data: (folderStructure) {
          return Row(
            children: [
              // Colonne 1: Arborescence des dossiers
              Container(
                width: 250,
                color: Colors.grey[100],
                child: Column(
                  children: [
                    Container(
                      color: Colors.blue,
                      padding: const EdgeInsets.all(12),
                      child: const Text(
                        'Dossiers',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: FolderTreeWidget(
                          folder: folderStructure,
                          onFolderSelected: (folder) {
                            ref.read(selectedFolderProvider.notifier).state =
                                folder;
                            ref.read(selectedImageProvider.notifier).state =
                                null;
                          },
                          selectedFolder: selectedFolder,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Colonne 2: Contenu du dossier sélectionné
              if (selectedFolder != null)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        color: Colors.blue,
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.folder_open,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Images',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    selectedFolder.path,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ImageGridWidget(
                          folderPath: selectedFolder.path,
                          onImageSelected: (image) {
                            ref.read(selectedImageProvider.notifier).state =
                                image;
                          },
                          selectedImage: selectedImage,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: Text(
                        'Sélectionnez un dossier pour voir les images',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              // Colonne 3: Visualisation de l'image sélectionnée
              if (selectedImage != null)
                Expanded(
                  flex: 2,
                  child: ImageViewerWidget(image: selectedImage),
                ),
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
}
