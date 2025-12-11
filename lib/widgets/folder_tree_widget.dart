import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final isSelected = selectedFolder?.id == folder.id;
    final isExpanded = ref.watch(expandedFoldersProvider(folder.id));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              onFolderSelected(folder);
              if (folder.subfolders.isNotEmpty) {
                ref.read(expandedFoldersProvider(folder.id).notifier).state =
                    !isExpanded;
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: EdgeInsets.only(
                left: level * 8.0,
                right: 4,
                top: 3,
                bottom: 3,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                children: [
                  // Icône d'expansion
                  if (folder.subfolders.isNotEmpty)
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 4),
                  // Icône du dossier
                  Icon(
                    isExpanded && folder.subfolders.isNotEmpty
                        ? Icons.folder_open_rounded
                        : Icons.folder_rounded,
                    size: 18,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.amber[600],
                  ),
                  const SizedBox(width: 8),
                  // Nom du dossier
                  Expanded(
                    child: Text(
                      folder.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ),
                  // Nombre de sous-dossiers
                  if (folder.subfolders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        folder.subfolders.length.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                ],
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
