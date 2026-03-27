import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/file_provider.dart';

class ImageGridWidget extends ConsumerWidget {
  final String folderPath;
  final Function(ImageModel) onImageSelected;
  final ImageModel? selectedImage;

  const ImageGridWidget({
    super.key,
    required this.folderPath,
    required this.onImageSelected,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    final imagesAsync = ref.watch(folderImagesProvider(folderPath));

    return imagesAsync.when(
      data: (images) {
        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 64,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune image dans ce dossier',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            final isSelected = selectedImage?.id == image.id;

            return GestureDetector(
              onTap: () {
                onImageSelected(image);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedScale(
                  scale: isSelected ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : scheme.outline.withValues(alpha: 0.35),
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(image.path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: scheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.broken_image,
                                  color: scheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        // Image name
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Tooltip(
                            message: image.name,
                            child: Text(
                              image.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Selection indicator
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
            Text('Erreur: $error'),
          ],
        ),
      ),
    );
  }
}
