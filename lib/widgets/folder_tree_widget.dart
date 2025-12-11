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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            onFolderSelected(folder);
            ref.read(expandedFoldersProvider(folder.id).notifier).state =
                !isExpanded;
          },
          child: Container(
            color: isSelected ? Colors.blue.withValues(alpha: 0.2) : null,
            padding: EdgeInsets.only(left: level * 16.0, top: 4, bottom: 4),
            child: Row(
              children: [
                if (folder.subfolders.isNotEmpty)
                  Icon(
                    isExpanded ? Icons.folder_open : Icons.folder,
                    size: 20,
                    color: Colors.orange,
                  )
                else
                  const Icon(Icons.folder, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    folder.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
