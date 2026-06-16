import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/service_providers.dart';

/// Provider pour le chemin du dossier sélectionné (initialisé sur Documents de l'utilisateur)
class SelectedFolderPath extends AsyncNotifier<String> {
  @override
  Future<String> build() async {
    final pathsService = ref.watch(folderPathsServiceProvider);
    return await pathsService.getDocumentsPath();
  }

  void setPath(String path) {
    state = AsyncData(path);
  }
}

final selectedFolderPathProvider = AsyncNotifierProvider<SelectedFolderPath, String>(SelectedFolderPath.new);

final folderStructureProvider = FutureProvider<FolderModel>((ref) async {
  final folderPath = await ref.watch(selectedFolderPathProvider.future);
  final fileService = ref.watch(fileServiceProvider);
  return fileService.loadFolderStructure(folderPath);
});

final selectedFolderProvider = StateProvider<FolderModel?>((ref) => null);

final folderImagesProvider = FutureProvider.family<List<ImageModel>, String>((
  ref,
  folderPath,
) async {
  final fileService = ref.watch(fileServiceProvider);
  return fileService.loadImagesFromFolder(folderPath);
});

final selectedImageProvider = StateProvider<ImageModel?>((ref) => null);

final customFoldersProvider = StateProvider<List<String>>((ref) => []);

final segmentationModeProvider = StateProvider<bool>((ref) => false);

final standardFoldersProvider = FutureProvider<Map<String, String>>((ref) async {
  final pathsService = ref.watch(folderPathsServiceProvider);
  return pathsService.getStandardFolders();
});
