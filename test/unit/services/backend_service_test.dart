import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:segma/services/backend_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late BackendService backendService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    backendService = BackendService(baseUrl: 'http://localhost:8000', dio: mockDio);
  });

  group('BackendService Health Check', () {
    test('healthCheck returns data on success', () async {
      final mockResponse = Response(
        data: {'status': 'healthy', 'device': 'cuda'},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/v3/health'),
      );

      when(() => mockDio.get('/api/v3/health'))
          .thenAnswer((_) async => mockResponse);

      final result = await backendService.healthCheck();

      expect(result['status'], 'healthy');
      expect(result['device'], 'cuda');
    });

    test('healthCheck throws exception on error', () async {
      when(() => mockDio.get('/api/v3/health')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v3/health'),
          message: 'Connection failed',
        ),
      );

      expect(() => backendService.healthCheck(), throwsException);
    });
  });

  group('BackendService Inférence', () {
    test('segmentByPrompt returns SegmentationResult on success', () async {
      final mockData = {
        'image_path': '/path/test.jpg',
        'resolution': '100x100',
        'segmentation_dir': '/seg',
        'objects': []
      };

      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: mockData,
                statusCode: 200,
                requestOptions: RequestOptions(path: '/api/v3/segment'),
              ));

      final result = await backendService.segmentByPrompt('/path/test.jpg', 'test');

      expect(result.imagePath, '/path/test.jpg');
      verify(() => mockDio.post('/api/v3/segment', data: any(named: 'data'))).called(1);
    });
  });
}
