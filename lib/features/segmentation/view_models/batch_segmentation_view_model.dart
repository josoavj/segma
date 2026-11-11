import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/app/di/service_providers.dart';
import 'package:segma/core/errors/error_handler.dart';
import 'package:segma/core/logging/log_service.dart';
import 'package:segma/features/segmentation/view_models/segmentation_view_model.dart';

class BatchState {
  final bool isProcessing;
  final int current;
  final int total;
  final String? currentImage;
  final int successCount;
  final String? error;

  BatchState({
    this.isProcessing = false,
    this.current = 0,
    this.total = 0,
    this.currentImage,
    this.successCount = 0,
    this.error,
  });

  double get progress => total == 0 ? 0 : current / total;

  BatchState copyWith({
    bool? isProcessing,
    int? current,
    int? total,
    String? currentImage,
    int? successCount,
    String? error,
  }) {
    return BatchState(
      isProcessing: isProcessing ?? this.isProcessing,
      current: current ?? this.current,
      total: total ?? this.total,
      currentImage: currentImage ?? this.currentImage,
      successCount: successCount ?? this.successCount,
      error: error ?? this.error,
    );
  }
}

class BatchSegmentationNotifier extends StateNotifier<BatchState> {
  final Ref ref;
  BatchSegmentationNotifier(this.ref) : super(BatchState());

  Future<void> processFolder(
      String folderPath, String prompt, double threshold) async {
    state = BatchState(isProcessing: true, total: 0);

    try {
      final backendService = ref.read(backendServiceProvider);
      final fileService = ref.read(fileServiceProvider);
      final images = await fileService.loadImagesFromFolder(folderPath);
      state = state.copyWith(total: images.length);

      if (images.isEmpty) {
        state = state.copyWith(error: 'Aucune image trouvée dans ce dossier.');
        return;
      }

      for (var index = 0; index < images.length; index++) {
        final image = images[index];
        try {
          state = state.copyWith(currentImage: image.name);
          final uploadResult = await backendService.uploadImage(image.path);
          final backendPath = uploadResult['image_path'] as String;
          final result = await backendService.segmentByPrompt(
            backendPath,
            prompt,
            confidenceThreshold: threshold,
          );

          final uploadMap = ref.read(uploadedImagePathMapProvider);
          ref.read(uploadedImagePathMapProvider.notifier).state = {
            ...uploadMap,
            image.path: backendPath,
          };
          ref.read(segmentationHistoryProvider.notifier).state = [
            ...ref.read(segmentationHistoryProvider),
            result,
          ];

          state = state.copyWith(
            current: index + 1,
            successCount: state.successCount + 1,
          );
        } catch (e) {
          state = state.copyWith(
            current: index + 1,
            error: '${image.name}: ${AppErrorHandler.getFriendlyMessage(e)}',
          );
        }
      }
    } catch (e, stack) {
      final friendlyMsg = AppErrorHandler.getFriendlyMessage(e);
      state = state.copyWith(error: friendlyMsg);
      // On ne lance pas de notification globale car le BatchProgressDialog affiche déjà l'erreur
      logService.error("Batch Error: $e", stackTrace: stack.toString());
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  void reset() {
    state = BatchState();
  }
}

final batchSegmentationProvider =
    StateNotifierProvider<BatchSegmentationNotifier, BatchState>((ref) {
  return BatchSegmentationNotifier(ref);
});
