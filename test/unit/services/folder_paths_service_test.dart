import 'package:flutter_test/flutter_test.dart';
import 'package:segma/services/folder_paths_service.dart';

void main() {
  late FolderPathsService service;

  setUp(() {
    service = FolderPathsService();
  });

  group('FolderPathsService Tests', () {
    test('getFolderLabel should return localized labels', () {
      expect(service.getFolderLabel('Documents'), contains('Documents'));
      // Fix: Pictures should return Images
      expect(service.getFolderLabel('Pictures'), contains('Images'));
      expect(service.getFolderLabel('Downloads'), contains('Téléchargements'));
      expect(service.getFolderLabel('Bureau'), contains('Bureau'));
    });

    test('getFolderLabel should return basename for unknown folders', () {
      expect(service.getFolderLabel('/home/user/MySecretFolder'), 'MySecretFolder');
    });
  });
}
