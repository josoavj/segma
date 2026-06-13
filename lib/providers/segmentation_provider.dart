import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/models/models.dart';
import 'package:segma/config/backend_config.dart';
import 'package:segma/services/backend_service.dart';

// Service backend
final backendServiceProvider = Provider<BackendService>((ref) {
  return BackendService(baseUrl: AppConfig.backendUrl);
});

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
final interactivePointsProvider = StateProvider<List<InteractivePoint>>((ref) => []);

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
  @override
  Future<SegmentationResult?> build() async => null;

  Future<void> segment(String imagePath, {List<InteractivePoint>? points}) async {
    // Mettre à jour l'état de chargement
    ref.read(segmentationLoadingProvider.notifier).state = true;
    ref.read(segmentationErrorProvider.notifier).state = null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        final service = ref.read(backendServiceProvider);
        final prompt = ref.read(segmentationPromptProvider);
        final threshold = ref.read(confidenceThresholdProvider);
        final interactivePoints = points ?? ref.read(interactivePointsProvider);

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
          points: interactivePoints!.isNotEmpty ? interactivePoints : null,
        );

        // Mettre à jour les providers après succès
        ref.read(currentSegmentationProvider.notifier).state = result;
        final history = ref.read(segmentationHistoryProvider);
        ref.read(segmentationHistoryProvider.notifier).state = [
          ...history,
          result,
        ];
        ref.read(segmentationErrorProvider.notifier).state = null;

        return result;
      } catch (e) {
        ref.read(segmentationErrorProvider.notifier).state = e.toString();
        rethrow;
      } finally {
        // Toujours mettre à jour l'état de chargement à la fin
        ref.read(segmentationLoadingProvider.notifier).state = false;
      }
    });
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
