import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:segma/app/di/service_providers.dart';
import 'package:segma/features/home/data/file_service.dart';
import 'package:segma/features/home/models/image_model.dart';
import 'package:segma/features/segmentation/data/backend_service.dart';
import 'package:segma/features/segmentation/models/segmentation_model.dart';
import 'package:segma/features/segmentation/view_models/batch_segmentation_view_model.dart';

class MockBackendService extends Mock implements BackendService {}

class MockFileService extends Mock implements FileService {}

void main() {
  late ProviderContainer container;
  late MockBackendService mockBackend;
  late MockFileService mockFiles;

  setUp(() {
    mockBackend = MockBackendService();
    mockFiles = MockFileService();
    container = ProviderContainer(
      overrides: [
        backendServiceProvider.overrideWithValue(mockBackend),
        fileServiceProvider.overrideWithValue(mockFiles),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('processFolder uploads and segments each local image', () async {
    const imagePath = '/test/img.jpg';
    const backendPath = 'server-img.jpg';
    when(() => mockFiles.loadImagesFromFolder('/test')).thenAnswer(
      (_) async => [ImageModel.fromPath(imagePath, 'img.jpg')],
    );
    when(() => mockBackend.uploadImage(imagePath)).thenAnswer(
      (_) async => {'image_path': backendPath},
    );
    when(() => mockBackend.segmentByPrompt(
          backendPath,
          'car',
          confidenceThreshold: 0.5,
          points: const [],
        )).thenAnswer(
      (_) async => SegmentationResult(
        imageId: 'id',
        imagePath: backendPath,
        width: 100,
        height: 100,
        objects: [],
        segmentationDir: 'dir',
        createdAt: DateTime.now(),
      ),
    );

    await container
        .read(batchSegmentationProvider.notifier)
        .processFolder('/test', 'car', 0.5);

    final state = container.read(batchSegmentationProvider);
    expect(state.successCount, 1);
    expect(state.current, 1);
    expect(state.total, 1);
    expect(state.isProcessing, isFalse);
    verify(() => mockBackend.uploadImage(imagePath)).called(1);
    verify(() => mockBackend.segmentByPrompt(
          backendPath,
          'car',
          confidenceThreshold: 0.5,
          points: const [],
        )).called(1);
  });
}
