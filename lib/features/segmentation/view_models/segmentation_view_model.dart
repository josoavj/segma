import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/features/segmentation/models/segmentation_model.dart';
import 'package:segma/app/di/service_providers.dart';
import 'package:segma/core/notifications/notification_service.dart';
import 'package:segma/core/errors/error_handler.dart';
import 'package:dio/dio.dart';

// État de chargement de la segmentation
final segmentationLoadingProvider = StateProvider<bool>((ref) => false);

// Erreurs de segmentation
final segmentationErrorProvider = StateProvider<String?>((ref) => null);

// Résultat de segmentation actuel
final currentSegmentationProvider = StateProvider<SegmentationResult?>(
  (ref) => null,
);

// Prompt de segmentation
final segmentationPromptProvider = StateProvider<String>((ref) {
  return 'all objects';
});

// Points interactifs pour SAM
final interactivePointsProvider =
    StateProvider<List<InteractivePoint>>((ref) => []);

// Seuil de confiance (SAM 3 recommande 0.25)
final confidenceThresholdProvider = StateProvider<double>((ref) {
  return 0.25;
});

// Historique de segmentation
final segmentationHistoryProvider = StateProvider<List<SegmentationResult>>(
  (ref) => [],
);

// Infos du modèle SAM
final modelInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(backendServiceProvider);
  return service.getModelInfo();
});

// Health check du serveur
final healthCheckProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(backendServiceProvider);
  return service.healthCheck();
});

// Upload d'image
final uploadImageProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, imagePath) async {
    final service = ref.read(backendServiceProvider);
    return service.uploadImage(imagePath);
  },
);

// Cache local -> chemin backend pour éviter les uploads répétés
final uploadedImagePathMapProvider = StateProvider<Map<String, String>>(
  (ref) => {},
);

// Segmentation par prompt - AsyncNotifier pour éviter les modifications pendant construction
class SegmentationNotifier extends AsyncNotifier<SegmentationResult?> {
  int _requestGeneration = 0;

  @override
  Future<SegmentationResult?> build() async => null;

  Future<void> segment(
    String imagePath, {
    List<InteractivePoint>? points,
  }) async {
    final requestGeneration = ++_requestGeneration;
    // Mettre à jour l'état de chargement
    ref.read(segmentationLoadingProvider.notifier).state = true;
    ref.read(segmentationErrorProvider.notifier).state = null;

    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      try {
        final service = ref.read(backendServiceProvider);
        final prompt =
            points == null ? ref.read(segmentationPromptProvider) : null;
        final threshold = ref.read(confidenceThresholdProvider);
        final uploadMap = ref.read(uploadedImagePathMapProvider);
        var backendImagePath = uploadMap[imagePath];

        if (backendImagePath == null || backendImagePath.isEmpty) {
          final uploadResult = await service.uploadImage(imagePath);
          backendImagePath =
              (uploadResult['image_path'] as String?) ?? imagePath;
          ref.read(uploadedImagePathMapProvider.notifier).state = {
            ...uploadMap,
            imagePath: backendImagePath,
          };
        }

        final result = await service.segmentByPrompt(
          backendImagePath,
          prompt,
          confidenceThreshold: threshold,
          points: points ?? const [],
        );

        if (requestGeneration != _requestGeneration) return null;

        // Mettre à jour les providers après succès
        ref.read(currentSegmentationProvider.notifier).state = result;
        final history = ref.read(segmentationHistoryProvider);
        ref.read(segmentationHistoryProvider.notifier).state = [
          ...history,
          result,
        ];
        ref.read(segmentationErrorProvider.notifier).state = null;

        return result;
      } catch (e, stack) {
        if (requestGeneration != _requestGeneration) rethrow;
        final friendlyMsg = AppErrorHandler.getFriendlyMessage(e);
        ref.read(segmentationErrorProvider.notifier).state = friendlyMsg;
        ref.read(notificationServiceProvider.notifier).error(
              e,
              stackTrace: stack,
              critical: e
                  is! DioException, // Les erreurs réseau sont rarement "critiques" au sens dialogue bloquant
            );
        rethrow;
      } finally {
        // Toujours mettre à jour l'état de chargement à la fin
        if (requestGeneration == _requestGeneration) {
          ref.read(segmentationLoadingProvider.notifier).state = false;
        }
      }
    });
    if (requestGeneration == _requestGeneration) {
      state = nextState;
    }
  }

  void reset() {
    _requestGeneration++;
    state = const AsyncData(null);
    ref.read(currentSegmentationProvider.notifier).state = null;
    ref.read(segmentationErrorProvider.notifier).state = null;
    ref.read(segmentationLoadingProvider.notifier).state = false;
  }
}

final segmentImageProvider =
    AsyncNotifierProvider<SegmentationNotifier, SegmentationResult?>(
  SegmentationNotifier.new,
);

// Changement de modèle
final changeModelProvider =
    FutureProvider.family<Map<String, dynamic>, (String, String?)>((
  ref,
  params,
) async {
  final (modelType, device) = params;
  final service = ref.read(backendServiceProvider);
  return service.changeModel(modelType, device: device);
});
