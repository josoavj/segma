import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/services/file_service.dart';

final selectedFolderPathProvider = StateProvider<String>((ref) {
  return '/home'; // Chemin par défaut - À configurer
});

final folderStructureProvider = FutureProvider<FolderModel>((ref) async {
  final folderPath = ref.watch(selectedFolderPathProvider);
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

final segmentationHistoryProvider = StateProvider<List<SegmentationResult>>(
  (ref) => [],
);
