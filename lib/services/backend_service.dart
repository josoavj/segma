import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:segma/models/models.dart';

class BackendService {
  final Dio dio;
  final String baseUrl;

  BackendService({required this.baseUrl})
    : dio = Dio(BaseOptions(baseUrl: baseUrl)) {
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  /// Segmente une image à partir d'un point cliqué
  Future<SegmentationResult> segmentImageByPoint(
    SegmentationRequest request,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/segment/point',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final maskBytes = base64Decode(response.data['mask']);
        return SegmentationResult(
          imageId: request.imagePath.hashCode.toString(),
          imagePath: request.imagePath,
          maskData: maskBytes,
          width: response.data['width'],
          height: response.data['height'],
          confidence: (response.data['confidence'] as num).toDouble(),
          createdAt: DateTime.now(),
        );
      }
      throw Exception('Erreur de segmentation: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Segmente une image avec une boîte délimitatrice
  Future<SegmentationResult> segmentImageByBox(
    SegmentationRequest request,
  ) async {
    try {
      final response = await dio.post(
        '/api/v1/segment/box',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final maskBytes = base64Decode(response.data['mask']);
        return SegmentationResult(
          imageId: request.imagePath.hashCode.toString(),
          imagePath: request.imagePath,
          maskData: maskBytes,
          width: response.data['width'],
          height: response.data['height'],
          confidence: (response.data['confidence'] as num).toDouble(),
          createdAt: DateTime.now(),
        );
      }
      throw Exception('Erreur de segmentation: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Vérifie la santé du serveur backend
  Future<bool> healthCheck() async {
    try {
      final response = await dio.get('/api/v1/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
