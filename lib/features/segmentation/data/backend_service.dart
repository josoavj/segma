import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:segma/features/segmentation/models/segmentation_model.dart';
import 'package:segma/core/config/backend_config.dart';
import 'package:segma/features/segmentation/data/data_parser.dart';

class BackendService {
  final Dio dio;
  final String baseUrl;

  BackendService({required this.baseUrl, Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: BackendConfig.apiTimeout,
                receiveTimeout: BackendConfig.uploadTimeout,
                sendTimeout: BackendConfig.uploadTimeout,
                headers: {
                  'X-Client-Platform': Platform.operatingSystem,
                  'X-App-Version': '1.0.0',
                },
              ),
            ) {
    if (!kReleaseMode && dio == null) {
      this.dio.interceptors.add(LogInterceptor(
            responseBody: true,
            requestBody: true,
            error: true,
          ));
    }
  }

  /// Factory pour créer une instance avec la configuration par défaut
  factory BackendService.withConfig() {
    return BackendService(baseUrl: BackendConfig.backendUrl);
  }

  /// Vérifie la santé du serveur backend
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await dio.get('/api/v3/health');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload une image vers le serveur
  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw Exception('Fichier non trouvé: $imagePath');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
    });

    final response = await dio.post('/api/v3/upload', data: formData);

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  /// Segmente une image avec un prompt texte SAM 3.
  Future<SegmentationResult> segmentByPrompt(
    String filename,
    String? prompt, {
    double confidenceThreshold = 0.25,
    List<InteractivePoint> points = const [],
  }) async {
    final response = await dio.post(
      '/api/v3/segment',
      data: {
        'filename': filename,
        if (prompt != null && prompt.trim().isNotEmpty) 'prompt': prompt,
        if (points.isNotEmpty)
          'points': points.map((point) => point.toJson()).toList(),
        'confidence_threshold': confidenceThreshold,
      },
    );

    if (response.statusCode == 200) {
      return DataParser.convertToSegmentationResult(
        response.data as Map<String, dynamic>,
      );
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
    );
  }

  /// Obtient les informations du modèle SAM actuellement chargé
  Future<Map<String, dynamic>> getModelInfo() async {
    try {
      final response = await dio.get('/api/v3/model/info');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur fetch model info: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Change le modèle SAM ou le device
  Future<Map<String, dynamic>> changeModel(
    String modelType, {
    String? device,
  }) async {
    try {
      final payload = {
        'model_type': modelType,
        if (device != null) 'device': device,
      };

      final response = await dio.post('/api/v3/model/change', data: payload);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur change model: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
