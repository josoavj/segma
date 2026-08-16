import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/file_provider.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/widgets/image_grid_widget.dart';
import 'package:segma/widgets/image_viewer_widget.dart';
import 'package:segma/widgets/home/home_sidebar.dart';
import 'package:segma/widgets/home/image_grid_header.dart';
import 'package:segma/utils/error_handler.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderStructureAsync = ref.watch(folderStructureProvider);
    final selectedFolder = ref.watch(selectedFolderProvider);
    final selectedImage = ref.watch(selectedImageProvider);

    // Nettoyer les données de segmentation quand on change d'image
    ref.listen<ImageModel?>(selectedImageProvider, (previous, next) {
      if ((previous == null && next != null) ||
          (previous != null && next == null) ||
          (previous != null && next != null && previous.path != next.path)) {
        ref.read(currentSegmentationProvider.notifier).state = null;
        ref.read(segmentationErrorProvider.notifier).state = null;
        ref.read(segmentationLoadingProvider.notifier).state = false;
      }
    });

    return folderStructureAsync.when(
      data: (folderStructure) {
        if (selectedImage != null) {
          return ImageViewerScreen(image: selectedImage);
        }

        return Row(
          children: [
            HomeSidebar(
              folderStructure: folderStructure,
              selectedFolder: selectedFolder,
            ),
            if (selectedFolder != null)
              Expanded(
                child: Column(
                  children: [
                    ImageGridHeader(selectedFolder: selectedFolder),
                    Expanded(
                      child: ImageGridWidget(
                        folderPath: selectedFolder.path,
                        onImageSelected: (image) {
                          ref.read(selectedImageProvider.notifier).state = image;
                        },
                        selectedImage: selectedImage,
                      ),
                    ),
                  ],
                ),
              )
            else
              const _EmptyHomeState(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(AppErrorHandler.getFriendlyMessage(error)),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
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
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Aucun dossier sélectionné',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez un dossier dans\nla barre latérale pour afficher les images',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
