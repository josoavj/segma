import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/services/backend_service.dart';
import 'package:segma/providers/service_providers.dart';
import 'package:segma/models/models.dart';

class MockBackendService extends Mock implements BackendService {}

void main() {
  late ProviderContainer container;
  late MockBackendService mockBackend;

  setUp(() {
    mockBackend = MockBackendService();
    container = ProviderContainer(
      overrides: [
        backendServiceProvider.overrideWithValue(mockBackend),
      ],
    );
  });

  group('SegmentationProvider Tests', () {
    test('Initial states should be default', () {
      expect(container.read(segmentationLoadingProvider), false);
      expect(container.read(segmentationPromptProvider), 'all objects');
      expect(container.read(currentSegmentationProvider), isNull);
    });

    test('segment should upload and then segment', () async {
      const imagePath = 'local/image.jpg';
      const backendPath = 'server/image.jpg';
      
      when(() => mockBackend.uploadImage(imagePath))
          .thenAnswer((_) async => {'image_path': backendPath});
          
      when(() => mockBackend.segmentByPrompt(backendPath, any(), confidenceThreshold: any(named: 'confidenceThreshold')))
          .thenAnswer((_) async => SegmentationResult(
                imageId: 'id',
                imagePath: backendPath,
                width: 100,
                height: 100,
                objects: [],
                segmentationDir: 'dir',
                createdAt: DateTime.now(),
              ));

      await container.read(segmentImageProvider.notifier).segment(imagePath);
      
      expect(container.read(currentSegmentationProvider), isNotNull);
      expect(container.read(uploadedImagePathMapProvider)[imagePath], backendPath);
      verify(() => mockBackend.uploadImage(imagePath)).called(1);
    });

    test('interactive points should be manageable', () {
      final notifier = container.read(interactivePointsProvider.notifier);
      notifier.state = [const InteractivePoint(x: 0.1, y: 0.1)];
      
      expect(container.read(interactivePointsProvider).length, 1);
    });
  });
}
