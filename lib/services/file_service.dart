import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:segma/models/models.dart';

class FileService {
  /// Charge la structure des dossiers récursivement
  static Future<FolderModel> loadFolderStructure(String folderPath) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw Exception('Dossier non trouvé: $folderPath');
    }

    final root = FolderModel.root(folderPath);
    return _loadFolderRecursive(folder, root);
  }

  static Future<FolderModel> _loadFolderRecursive(
    Directory directory,
    FolderModel parent,
  ) async {
    final List<FolderModel> subfolders = [];
    final List<ImageModel> images = [];

    try {
      final entities = await directory.list().toList();

      for (final entity in entities) {
        if (entity is Directory) {
          final subfolder = FolderModel(
            id: entity.path.hashCode.toString(),
            path: entity.path,
            name: entity.path.split('/').last,
          );
          final loaded = await _loadFolderRecursive(entity, subfolder);
          subfolders.add(loaded);
        } else if (entity is File) {
          if (_isImageFile(entity.path)) {
            images.add(
              ImageModel.fromPath(entity.path, entity.path.split('/').last),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du dossier: $e');
    }

    return FolderModel(
      id: parent.id,
      path: parent.path,
      name: parent.name,
      subfolders: subfolders,
      images: images,
    );
  }

  static bool _isImageFile(String path) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerPath = path.toLowerCase();
    return extensions.any((ext) => lowerPath.endsWith(ext));
  }

  /// Charge les fichiers d'un dossier spécifique (non-récursif)
  static Future<List<ImageModel>> loadImagesFromFolder(
    String folderPath,
  ) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      return [];
    }

    final images = <ImageModel>[];
    try {
      final entities = await folder.list().toList();
      for (final entity in entities) {
        if (entity is File && _isImageFile(entity.path)) {
          images.add(
            ImageModel.fromPath(entity.path, entity.path.split('/').last),
          );
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des images: $e');
    }

    return images;
  }
}
