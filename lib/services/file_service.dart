import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:segma/models/models.dart';

class FileService {
  /// Charge la structure des dossiers de manière efficiente
  Future<FolderModel> loadFolderStructure(String folderPath) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw Exception('Dossier non trouvé: $folderPath');
    }

    final root = FolderModel.root(folderPath);
    return _loadFolderRecursive(folder, root, 0, 3);
  }

  Future<FolderModel> _loadFolderRecursive(
    Directory directory,
    FolderModel parent,
    int currentDepth,
    int maxDepth,
  ) async {
    if (currentDepth >= maxDepth) return parent;

    final List<FolderModel> subfolders = [];
    final List<ImageModel> images = [];

    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (_shouldIgnoreDirectory(entity.path)) continue;

        if (entity is Directory) {
          final name = p.basename(entity.path);
          final subfolder = FolderModel(
            id: entity.path.hashCode.toString(),
            path: entity.path,
            name: name,
          );
          final loaded = await _loadFolderRecursive(entity, subfolder, currentDepth + 1, maxDepth);
          subfolders.add(loaded);
        } else if (entity is File && _isImageFile(entity.path)) {
          images.add(
            ImageModel.fromPath(entity.path, p.basename(entity.path)),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur accès dossier ${directory.path}: $e');
    }

    return FolderModel(
      id: parent.id,
      path: parent.path,
      name: parent.name,
      subfolders: subfolders,
      images: images,
    );
  }

  bool _isImageFile(String path) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerPath = path.toLowerCase();
    return extensions.any((ext) => lowerPath.endsWith(ext));
  }

  bool _shouldIgnoreDirectory(String path) {
    final ignoredPatterns = ['.wine', '.proton', '.steam', '.cache', '.config', '.local', '.mozilla', 'snap'];
    for (final segment in path.split('/')) {
      if (ignoredPatterns.contains(segment)) return true;
    }
    return path.contains('.wine/dosdevices/z:');
  }

  Future<List<ImageModel>> loadImagesFromFolder(String folderPath) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) return [];

    final images = <ImageModel>[];
    try {
      await for (final entity in folder.list()) {
        if (entity is File && _isImageFile(entity.path)) {
          images.add(ImageModel.fromPath(entity.path, p.basename(entity.path)));
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement images: $e');
    }
    return images;
  }

  Future<Directory> _createSegmentationFolder(String imagePath) async {
    final imageFile = File(imagePath);
    final parentDir = imageFile.parent;
    final imageNameWithoutExt = p.basenameWithoutExtension(imageFile.path);

    try {
      final segDir = Directory(p.join(parentDir.path, '.segmentation', imageNameWithoutExt));
      if (!await segDir.exists()) await segDir.create(recursive: true);
      return segDir;
    } catch (e) {
      final tempDir = await getTemporaryDirectory();
      final fallbackDir = Directory(p.join(tempDir.path, 'segma_cache', imageNameWithoutExt));
      if (!await fallbackDir.exists()) await fallbackDir.create(recursive: true);
      return fallbackDir;
    }
  }

  Future<String> saveMask(String imagePath, Uint8List maskData, String objectName) async {
    final segmentationDir = await _createSegmentationFolder(imagePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final maskPath = p.join(segmentationDir.path, '${objectName}_$timestamp.mask');
    await File(maskPath).writeAsBytes(maskData);
    return maskPath;
  }

  Future<Uint8List> loadMask(String maskPath) async {
    final file = File(maskPath);
    if (!await file.exists()) throw Exception('Masque non trouvé');
    return await file.readAsBytes();
  }

  Future<void> deleteMask(String maskPath) async {
    final file = File(maskPath);
    if (await file.exists()) await file.delete();
    final parentDir = file.parent;
    if (await parentDir.exists() && (await parentDir.list().isEmpty)) {
      await parentDir.delete();
    }
  }
}
