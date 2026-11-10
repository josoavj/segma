import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/models/models.dart';

class FolderTreeWidget extends ConsumerWidget {
  final FolderModel folder;
  final Function(FolderModel) onFolderSelected;
  final FolderModel? selectedFolder;
  final int level;

  const FolderTreeWidget({
    super.key,
    required this.folder,
    required this.onFolderSelected,
    this.selectedFolder,
    this.level = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedFolder?.id == folder.id;
    final isExpanded = ref.watch(expandedFoldersProvider(folder.id));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Material(
            color: isSelected
                ? scheme.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                onFolderSelected(folder);
                if (folder.subfolders.isNotEmpty) {
                  ref.read(expandedFoldersProvider(folder.id).notifier).state =
                      !isExpanded;
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  8.0 + (level * 12.0),
                  8,
                  8,
                  8,
                ),
                decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(
                          color: scheme.primary.withValues(alpha: 0.4),
                          width: 1.5,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Icône d'expansion
                    if (folder.subfolders.isNotEmpty)
                      AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: isSelected
                              ? scheme.primary
                              : scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      )
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 6),
                    // Icône du dossier
                    Icon(
                      isExpanded && folder.subfolders.isNotEmpty
                          ? Icons.folder_open_rounded
                          : Icons.folder_rounded,
                      size: 20,
                      color: isSelected ? scheme.primary : Colors.amber[600],
                    ),
                    const SizedBox(width: 10),
                    // Nom du dossier
                    Expanded(
                      child: Text(
                        folder.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                    ),
                    // Badge de contenu (nombre de sous-dossiers ou images)
                    if (folder.subfolders.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? scheme.primary
                              : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          folder.subfolders.length.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Sous-dossiers
        if (isExpanded && folder.subfolders.isNotEmpty)
          ...folder.subfolders.map((subfolder) {
            return FolderTreeWidget(
              folder: subfolder,
              onFolderSelected: onFolderSelected,
              selectedFolder: selectedFolder,
              level: level + 1,
            );
          }),
      ],
    );
  }
}

final expandedFoldersProvider = StateProvider.family<bool, String>(
  (ref, folderId) => false,
);
