import 'package:flutter_test/flutter_test.dart';
import 'package:segma/services/folder_paths_service.dart';

void main() {
  late FolderPathsService service;

  setUp(() {
    service = FolderPathsService();
  });

  group('FolderPathsService Tests', () {
    test('getFolderLabel should return localized labels', () {
      expect(service.getFolderLabel('Documents'), 'Documents');
      expect(service.getFolderLabel('Pictures'), 'Images');
      expect(service.getFolderLabel('Downloads'), 'Téléchargements');
      expect(service.getFolderLabel('Bureau'), 'Bureau');
    });

    test('getFolderLabel should return basename for unknown folders', () {
      expect(service.getFolderLabel('/home/user/MySecretFolder'), 'MySecretFolder');
    });
  });
}
