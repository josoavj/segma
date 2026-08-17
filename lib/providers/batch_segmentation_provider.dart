import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/service_providers.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/utils/error_handler.dart';

import '../services/log_service.dart';

class BatchState {
  final bool isProcessing;
  final int current;
  final int total;
  final String? currentImage;
  final List<SegmentationResult> results;
  final String? error;

  BatchState({
    this.isProcessing = false,
    this.current = 0,
    this.total = 0,
    this.currentImage,
    this.results = const [],
    this.error,
  });

  double get progress => total == 0 ? 0 : current / total;

  BatchState copyWith({
    bool? isProcessing,
    int? current,
    int? total,
    String? currentImage,
    List<SegmentationResult>? results,
    String? error,
  }) {
    return BatchState(
      isProcessing: isProcessing ?? this.isProcessing,
      current: current ?? this.current,
      total: total ?? this.total,
      currentImage: currentImage ?? this.currentImage,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }
}

class BatchSegmentationNotifier extends StateNotifier<BatchState> {
  final Ref ref;
  BatchSegmentationNotifier(this.ref) : super(BatchState());

  Future<void> processFolder(String folderPath, String prompt, double threshold) async {
    state = BatchState(isProcessing: true, total: 0);

    try {
      final backendService = ref.read(backendServiceProvider);
      
      final response = await backendService.dio.post(
        '/api/v3/segment/batch',
        data: {
          'filename': folderPath,
          'prompt': prompt,
          'confidence_threshold': threshold,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final responseBody = response.data as ResponseBody;
      final stream = responseBody.stream.cast<List<int>>();
      
      await for (final chunk in stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.trim().isEmpty) continue;
        
        try {
          final Map<String, dynamic> update = jsonDecode(chunk);
          
          if (update['status'] == 'success') {
            final result = SegmentationResult.fromJson(update['result']);
            
            state = state.copyWith(
              current: update['current'],
              total: update['total'],
              currentImage: update['image_path'],
              results: [...state.results, result],
            );
            
            ref.read(segmentationHistoryProvider.notifier).update((history) => [...history, result]);
          } else if (update['status'] == 'error') {
             final errorData = update['error'];
             state = state.copyWith(
              current: update['current'],
              total: update['total'],
              error: errorData is String ? errorData : AppErrorHandler.getFriendlyMessage(errorData),
            );
          }
        } catch (e) {
          continue;
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

final batchSegmentationProvider = StateNotifierProvider<BatchSegmentationNotifier, BatchState>((ref) {
  return BatchSegmentationNotifier(ref);
});
