import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:segma/services/file_service.dart';

void main() {
  late FileService fileService;
  late Directory tempDir;

  setUp(() async {
    fileService = FileService();
    tempDir = await Directory.systemTemp.createTemp('segma_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileService Tests', () {
    test('loadImagesFromFolder should find image files', () async {
      // Créer quelques fichiers
      await File(p.join(tempDir.path, 'image1.jpg')).create();
      await File(p.join(tempDir.path, 'image2.png')).create();
      await File(p.join(tempDir.path, 'notes.txt')).create();
      
      final images = await fileService.loadImagesFromFolder(tempDir.path);
      
      expect(images.length, 2);
      expect(images.any((img) => img.name == 'image1.jpg'), true);
      expect(images.any((img) => img.name == 'image2.png'), true);
    });

    test('saveMask and loadMask should work', () async {
      final imagePath = p.join(tempDir.path, 'test.jpg');
      await File(imagePath).create();
      
      final maskData = Uint8List.fromList([1, 2, 3, 4]);
      final maskPath = await fileService.saveMask(imagePath, maskData, 'bolt');
      
      expect(await File(maskPath).exists(), true);
      expect(maskPath.contains('.segmentation'), true);
      
      final loadedData = await fileService.loadMask(maskPath);
      expect(loadedData, maskData);
    });

    test('loadFolderStructure should respect maxDepth and ignore patterns', () async {
      final subDir = await Directory(p.join(tempDir.path, 'sub')).create();
      final ignoredDir = await Directory(p.join(tempDir.path, '.cache')).create();
      
      await File(p.join(subDir.path, 'inner.jpg')).create();
      await File(p.join(ignoredDir.path, 'hidden.jpg')).create();
      
      final structure = await fileService.loadFolderStructure(tempDir.path);
      
      expect(structure.subfolders.any((f) => f.name == 'sub'), true);
      expect(structure.subfolders.any((f) => f.name == '.cache'), false);
    });
  });
}
