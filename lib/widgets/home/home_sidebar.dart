import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/file_provider.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/providers/batch_segmentation_provider.dart';
import 'package:segma/providers/service_providers.dart';
import 'package:segma/widgets/folder_tree_widget.dart';
import 'package:segma/widgets/folder_picker_widget.dart';
import 'package:segma/widgets/batch_progress_dialog.dart';
import 'package:segma/utils/error_handler.dart';
import 'package:segma/services/notification_service.dart';

class HomeSidebar extends ConsumerWidget {
  final FolderModel folderStructure;
  final FolderModel? selectedFolder;

  const HomeSidebar({
    super.key,
    required this.folderStructure,
    this.selectedFolder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 280,
      color: scheme.surface,
      child: Column(
        children: [
          // En-tête avec sélecteur de dossier
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  scheme.primary,
                  scheme.primary.withValues(alpha: 0.8),
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
                    Icon(Icons.folder_special, color: scheme.onPrimary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dossiers',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFolderButtons(context, ref),
                const SizedBox(height: 12),
                // Bouton Batch Processing
                Consumer(
                  builder: (context, ref, child) {
                    final selectedFolder = ref.watch(selectedFolderProvider);
                    return ElevatedButton.icon(
                      onPressed: selectedFolder == null
                          ? null
                          : () => _showBatchProcessDialog(context, ref, selectedFolder),
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text(
                          'Traiter le dossier',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.secondaryContainer,
                        foregroundColor: scheme.onSecondaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildCustomFolderButton(context, ref),
              ],
            ),
          ),

          Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.5)),

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
    final scheme = Theme.of(context).colorScheme;
    final standardFoldersAsync = ref.watch(standardFoldersProvider);

    return standardFoldersAsync.when(
      data: (folders) {
        final customFolders = ref.watch(customFoldersProvider);

        return Column(
          children: [
            // Dossiers standards
            _buildFolderButton(
              context,
              ref,
              'Documents',
              folders['documents']!,
            ),
            const SizedBox(height: 8),
            _buildFolderButton(context, ref, 'Images', folders['images']!),
            const SizedBox(height: 8),
            _buildFolderButton(
              context,
              ref,
              'Téléchargements',
              folders['downloads']!,
            ),
            const SizedBox(height: 8),
            _buildFolderButton(context, ref, 'Bureau', folders['desktop']!),

            // Dossiers personnalisés
            if (customFolders.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: scheme.onPrimary.withValues(alpha: 0.2), height: 1),
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
                    folderName,
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
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(color: scheme.onPrimary, strokeWidth: 2),
        ),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          AppErrorHandler.getFriendlyMessage(err),
          style: TextStyle(
            color: scheme.onPrimary.withValues(alpha: 0.7),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCustomFolderButton(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

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
              color: scheme.onPrimary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, size: 18, color: scheme.onPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ajouter un dossier',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: scheme.onPrimary,
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

  void _showBatchProcessDialog(
    BuildContext context,
    WidgetRef ref,
    FolderModel folder,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const BatchProgressDialog(),
    );

    final prompt = ref.read(segmentationPromptProvider);
    final threshold = ref.read(confidenceThresholdProvider);

    ref
        .read(batchSegmentationProvider.notifier)
        .processFolder(folder.path, prompt, threshold);
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
              try {
                final folder = await ref
                    .read(fileServiceProvider)
                    .loadFolderStructure(path);
                final customFolders = ref.read(customFoldersProvider);
                if (!customFolders.contains(path)) {
                  ref.read(customFoldersProvider.notifier).state = [
                    ...customFolders,
                    path,
                  ];
                }
                ref.read(selectedFolderProvider.notifier).state = folder;
                ref.read(selectedImageProvider.notifier).state = null;
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e, stack) {
                ref.read(notificationServiceProvider.notifier).error(e, stackTrace: stack);
              }
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
      color: isDarkMode
          ? Colors.grey[800]?.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          try {
            final folder = await ref
                .read(fileServiceProvider)
                .loadFolderStructure(path);
            ref.read(selectedFolderProvider.notifier).state = folder;
            ref.read(selectedImageProvider.notifier).state = null;
          } catch (e, stack) {
            ref.read(notificationServiceProvider.notifier).error(e, stackTrace: stack);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
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
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
    final scheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDarkMode
          ? scheme.surfaceContainerHigh.withValues(alpha: 0.5)
          : scheme.surfaceContainer.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          try {
            final folder = await ref
                .read(fileServiceProvider)
                .loadFolderStructure(path);
            ref.read(selectedFolderProvider.notifier).state = folder;
            ref.read(selectedImageProvider.notifier).state = null;
          } catch (e, stack) {
            ref.read(notificationServiceProvider.notifier).error(e, stackTrace: stack);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
