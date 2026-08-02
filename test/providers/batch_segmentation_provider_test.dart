import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:segma/providers/batch_segmentation_provider.dart';
import 'package:segma/services/backend_service.dart';
import 'package:segma/providers/service_providers.dart';
import 'package:segma/models/models.dart';

class MockBackendService extends Mock implements BackendService {}
class MockDio extends Mock implements Dio {}

void main() {
  late ProviderContainer container;
  late MockBackendService mockBackend;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockBackend = MockBackendService();
    mockDio = MockDio();
    
    when(() => mockBackend.dio).thenReturn(mockDio);
    when(() => mockBackend.baseUrl).thenReturn('http://test');

    container = ProviderContainer(
      overrides: [
        backendServiceProvider.overrideWithValue(mockBackend),
      ],
    );
  });

  group('BatchSegmentationProvider Tests', () {
    test('processFolder should handle streaming results', () async {
      final controller = StreamController<Uint8List>();
      
      final mockResponse = Response(
        data: ResponseBody(controller.stream, 200),
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/v3/segment/batch'),
      );

      when(() => mockDio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer((_) async => mockResponse);

      final notifier = container.read(batchSegmentationProvider.notifier);
      final future = notifier.processFolder('/test', 'prompt', 0.5);

      final update = {
        'status': 'success',
        'current': 1,
        'total': 1,
        'image_path': 'img.jpg',
        'result': {
          'image_path': 'img.jpg',
          'resolution': '100x100',
          'segmentation_dir': 'dir',
          'objects': []
        }
      };
      
      controller.add(Uint8List.fromList(utf8.encode(jsonEncode(update) + '\n')));
      await controller.close();
      await future;

      final state = container.read(batchSegmentationProvider);
      expect(state.results.length, 1);
      expect(state.current, 1);
      expect(state.isProcessing, false);
    });
  });
}
