import 'dart:io';
import 'package:dio/dio.dart';
import 'package:segma/models/models.dart';
import 'package:segma/config/backend_config.dart';

class BackendService {
  final Dio dio;
  final String baseUrl;

  BackendService({required this.baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: AppConfig.apiTimeout,
          receiveTimeout: AppConfig.uploadTimeout,
        ),
      ) {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  /// Factory pour créer une instance avec la configuration par défaut
  factory BackendService.withConfig() {
    return BackendService(baseUrl: AppConfig.backendUrl);
  }

  /// Vérifie la santé du serveur backend
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await dio.get('/api/v3/health');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Erreur health check: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Upload une image vers le serveur
  Future<Map<String, dynamic>> uploadImage(String imagePath) async {
    try {
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
      throw Exception('Erreur upload: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau upload: ${e.message}');
    }
  }

  /// Segmente une image avec un prompt texte
  Future<SegmentationResult> segmentByPrompt(
    String imagePath,
    String prompt, {
    double confidenceThreshold = 0.25,
  }) async {
    try {
      final request = SegmentationRequest(
        imagePath: imagePath,
        prompt: prompt,
        confidenceThreshold: confidenceThreshold,
      );

      final response = await dio.post(
        '/api/v3/segment',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return SegmentationResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Erreur segmentation: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
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
