import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/models/models.dart';
import 'package:segma/services/file_service.dart';
import 'package:segma/services/folder_paths_service.dart';

/// Provider pour le chemin du dossier sélectionné (initialisé sur Documents de l'utilisateur)
class SelectedFolderPath extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    return await FolderPathsService.getDocumentsPath();
  }

  void setPath(String path) {
    state = AsyncData(path);
  }
}

final selectedFolderPathProvider = AsyncNotifierProvider<SelectedFolderPath, String>(SelectedFolderPath.new);

final folderStructureProvider = FutureProvider<FolderModel>((ref) async {
  final folderPath = await ref.watch(selectedFolderPathProvider.future);
  return FileService.loadFolderStructure(folderPath);
});

final selectedFolderProvider = StateProvider<FolderModel?>((ref) {
  return null;
});

final folderImagesProvider = FutureProvider.family<List<ImageModel>, String>((
  ref,
  folderPath,
) async {
  return FileService.loadImagesFromFolder(folderPath);
});

final selectedImageProvider = StateProvider<ImageModel?>((ref) {
  return null;
});

final customFoldersProvider = StateProvider<List<String>>((ref) {
  return [];
});

final segmentationModeProvider = StateProvider<bool>((ref) {
  return false; // true quand on est en mode segmentation
});

final standardFoldersProvider = FutureProvider<Map<String, String>>((ref) async {
  return FolderPathsService.getStandardFolders();
});
