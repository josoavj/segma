import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/services/notification_service.dart';

class FolderPickerWidget extends ConsumerStatefulWidget {
  final Function(String) onFolderSelected;

  const FolderPickerWidget({super.key, required this.onFolderSelected});

  @override
  ConsumerState<FolderPickerWidget> createState() => _FolderPickerWidgetState();
}

class _FolderPickerWidgetState extends ConsumerState<FolderPickerWidget> {
  late String currentPath;
  List<FileSystemEntity> _entities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentPath = '/home';
    _loadDirectory(currentPath);
  }

  Future<void> _loadDirectory(String path) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dir = Directory(path);
      if (await dir.exists()) {
        final entities = await dir.list().toList();
        entities.sort((a, b) {
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;
          if (aIsDir != bIsDir) {
            return bIsDir ? 1 : -1;
          }
          return a.path.compareTo(b.path);
        });

        setState(() {
          _entities = entities.whereType<Directory>().toList();
          currentPath = path;
        });
      }
    } catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider.notifier).error('Erreur: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goUp() {
    final parent = File(currentPath).parent.path;
    if (parent != currentPath) {
      _loadDirectory(parent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Navigation bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: scheme.outline.withValues(alpha: 0.35)),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: _goUp,
                tooltip: 'Dossier parent',
              ),
              Expanded(
                child: Text(
                  currentPath,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: () => widget.onFolderSelected(currentPath),
                tooltip: 'Sélectionner ce dossier',
                color: scheme.tertiary,
              ),
            ],
          ),
        ),
        // Folder list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _entities.isEmpty
              ? const Center(child: Text('Aucun dossier'))
              : ListView.builder(
                  itemCount: _entities.length,
                  itemBuilder: (context, index) {
                    final entity = _entities[index];
                    final folderName = entity.path.split('/').last;

                    return ListTile(
                      leading: Icon(Icons.folder, color: scheme.primary),
                      title: Text(folderName),
                      onTap: () => _loadDirectory((entity as Directory).path),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
