import 'dart:io';
import 'package:path/path.dart' as path;

/// Service pour gérer les chemins de dossiers système
/// Gère les variations de noms selon la langue du système
class FolderPathsService {
  /// Obtient le dossier home de l'utilisateur
  String getHomeDirectory() {
    final homeEnv = Platform.environment['HOME'];
    if (homeEnv != null) return homeEnv;

    // Windows
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) return userProfile;

    throw Exception('Impossible de déterminer le dossier home');
  }

  /// Obtient le chemin du dossier Documents (adapté à la langue)
  Future<String> getDocumentsPath() async {
    return _findLocalizedPath(['Documents', 'Документы', '文档', 'Dokumenty']);
  }

  /// Obtient le chemin du dossier Images/Photos (adapté à la langue)
  Future<String> getPicturesPath() async {
    return _findLocalizedPath([
      'Pictures',
      'Photos',
      'Images',
      'Изображения',
      '图片',
      'Galeria',
      'Bilder',
      'Ilustracje',
    ]);
  }

  /// Obtient le chemin du dossier Downloads (adapté à la langue)
  Future<String> getDownloadsPath() async {
    return _findLocalizedPath([
      'Downloads',
      'Pobrane',
      'Téléchargements',
      'Загрузки',
      '下载',
      'Descargas',
      'Scaricati',
    ]);
  }

  /// Obtient le chemin du dossier Desktop (adapté à la langue)
  Future<String> getDesktopPath() async {
    return _findLocalizedPath([
      'Desktop',
      'Bureau',
      'Escritorio',
      'Рабочий стол',
      '桌面',
      'Pulpit',
    ]);
  }

  /// Cherche le premier dossier qui existe parmi les variantes
  Future<String> _findLocalizedPath(List<String> variants) async {
    final home = getHomeDirectory();

    for (final variant in variants) {
      final candidatePath = path.join(home, variant);
      if (await Directory(candidatePath).exists()) {
        return candidatePath;
      }
    }

    // Si aucune variante n'existe, créer et retourner la première
    final defaultPath = path.join(home, variants.first);
    await Directory(defaultPath).create(recursive: true);
    return defaultPath;
  }

  /// Obtient les dossiers standard de l'utilisateur
  Future<Map<String, String>> getStandardFolders() async {
    return {
      'documents': await getDocumentsPath(),
      'images': await getPicturesPath(),
      'downloads': await getDownloadsPath(),
      'desktop': await getDesktopPath(),
    };
  }

  /// Affiche un label lisible pour un dossier
  String getFolderLabel(String folderPath) {
    final folderName = path.basename(folderPath);

    final labels = {
      'documents': '📄 Documents',
      'Documents': '📄 Documents',
      'Dokumenty': '📄 Documents',
      'Документы': '📄 Documents',
      '文档': '📄 Documents',
      'pictures': '🖼️ Images',
      'Photos': '🖼️ Images',
      'Images': '🖼️ Images',
      'Изображения': '🖼️ Images',
      '图片': '🖼️ Images',
      'Galeria': '🖼️ Images',
      'Bilder': '🖼️ Images',
      'Ilustracje': '🖼️ Images',
      'downloads': '⬇️ Téléchargements',
      'Downloads': '⬇️ Téléchargements',
      'Pobrane': '⬇️ Téléchargements',
      'Téléchargements': '⬇️ Téléchargements',
      'Загрузки': '⬇️ Téléchargements',
      '下载': '⬇️ Téléchargements',
      'Descargas': '⬇️ Téléchargements',
      'Scaricati': '⬇️ Téléchargements',
      'desktop': '🖥️ Bureau',
      'Desktop': '🖥️ Bureau',
      'Bureau': '🖥️ Bureau',
      'Escritorio': '🖥️ Bureau',
      'Рабочий стол': '🖥️ Bureau',
      '桌面': '🖥️ Bureau',
      'Pulpit': '🖥️ Bureau',
    };

    return labels[folderName] ?? folderName;
  }
}
