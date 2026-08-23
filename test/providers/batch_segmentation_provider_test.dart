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

class MockBackendService extends Mock implements BackendService {}
class MockDio extends Mock implements Dio {}
class FakeOptions extends Fake implements Options {}

void main() {
  late ProviderContainer container;
  late MockBackendService mockBackend;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(FakeOptions());
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
      
      final ndjson = '${jsonEncode(update)}\n';
      // Utiliser un Stream.value pour éviter les timeouts
      final stream = Stream.value(Uint8List.fromList(utf8.encode(ndjson)));
      
      final mockResponse = Response(
        data: ResponseBody(stream, 200),
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/v3/segment/batch'),
      );

      when(() => mockDio.post(
        any(), 
        data: any(named: 'data'), 
        options: any(named: 'options')
      )).thenAnswer((_) async => mockResponse);

      final notifier = container.read(batchSegmentationProvider.notifier);
      
      // On attend la fin du traitement
      await notifier.processFolder('/test', 'prompt', 0.5);

      final state = container.read(batchSegmentationProvider);
      
      // Si le test échoue ici, c'est que le stream n'a pas été bien transformé
      // ou que jsonDecode a échoué.
      expect(state.successCount, 1, reason: 'Erreur: ${state.error}');
      expect(state.current, 1);
    });
  });
}
