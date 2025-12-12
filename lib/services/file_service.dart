import 'dart:io';
import 'dart:typed_data';
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
        // Ignorer les répertoires problématiques
        if (_shouldIgnoreDirectory(entity.path)) {
          continue;
        }

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

  /// Vérifie si un répertoire doit être ignoré
  static bool _shouldIgnoreDirectory(String path) {
    // Ignorer les répertoires Wine/Proton et système
    final ignoredPatterns = [
      '.wine',
      '.proton',
      '.steam',
      '.cache',
      '.config',
      '.local',
      '.mozilla',
      'snap',
    ];

    // Vérifier chaque segment du chemin
    for (final segment in path.split('/')) {
      if (ignoredPatterns.contains(segment)) {
        return true;
      }
    }

    // Ignorer les chemins récursifs Wine
    if (path.contains('.wine/dosdevices/z:')) {
      return true;
    }

    return false;
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

  /// Crée le dossier de segmentation pour une image
  static Future<Directory> _createSegmentationFolder(String imagePath) async {
    final imageFile = File(imagePath);
    final parentDir = imageFile.parent.path;
    final imageNameWithoutExt = imageFile.path.split('/').last.split('.').first;

    final segmentationDir = Directory(
      '$parentDir/.segmentation/$imageNameWithoutExt',
    );

    if (!await segmentationDir.exists()) {
      await segmentationDir.create(recursive: true);
    }

    return segmentationDir;
  }

  /// Sauvegarde un masque binaire pour une image
  static Future<String> saveMask(
    String imagePath,
    Uint8List maskData,
    String objectName,
  ) async {
    try {
      final segmentationDir = await _createSegmentationFolder(imagePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final maskPath = '${segmentationDir.path}/${objectName}_$timestamp.mask';

      final maskFile = File(maskPath);
      await maskFile.writeAsBytes(maskData);

      return maskPath;
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du masque: $e');
      rethrow;
    }
  }

  /// Charge un masque binaire
  static Future<Uint8List> loadMask(String maskPath) async {
    try {
      final maskFile = File(maskPath);
      if (!await maskFile.exists()) {
        throw Exception('Fichier masque non trouvé: $maskPath');
      }
      return await maskFile.readAsBytes();
    } catch (e) {
      debugPrint('Erreur lors du chargement du masque: $e');
      rethrow;
    }
  }

  /// Supprime un masque et son dossier s'il est vide
  static Future<void> deleteMask(String maskPath) async {
    try {
      final maskFile = File(maskPath);
      if (await maskFile.exists()) {
        await maskFile.delete();
      }

      // Vérifier si le dossier est vide et le supprimer
      final parentDir = maskFile.parent;
      final files = await parentDir.list().toList();
      if (files.isEmpty) {
        await parentDir.delete();
      }
    } catch (e) {
      debugPrint('Erreur lors de la suppression du masque: $e');
    }
  }
}
