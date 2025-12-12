import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/services/backend_service.dart';

final backendServiceProvider = Provider<BackendService>((ref) {
  return BackendService(
    baseUrl: 'http://localhost:8000', // À configurer via environment
  );
});

final segmentationLoadingProvider = StateProvider<bool>((ref) => false);

final segmentationErrorProvider = StateProvider<String?>((ref) => null);

final currentSegmentationProvider = StateProvider<SegmentationResult?>(
  (ref) => null,
);

final segmentationHistoryProvider = StateProvider<List<SegmentationResult>>(
  (ref) => [],
);

final segmentationProvider =
    FutureProvider.family<SegmentationResult, SegmentationRequest>((
      ref,
      request,
    ) async {
      ref.read(segmentationLoadingProvider.notifier).state = true;
      ref.read(segmentationErrorProvider.notifier).state = null;

      try {
        final service = ref.read(backendServiceProvider);
        final result = await service.segmentImageByPoint(request);
        ref.read(currentSegmentationProvider.notifier).state = result;

        // Ajouter à l'historique
        final history = ref.read(segmentationHistoryProvider);
        ref.read(segmentationHistoryProvider.notifier).state = [
          ...history,
          result,
        ];

        return result;
      } catch (e) {
        ref.read(segmentationErrorProvider.notifier).state = e.toString();
        rethrow;
      } finally {
        ref.read(segmentationLoadingProvider.notifier).state = false;
      }
    });
