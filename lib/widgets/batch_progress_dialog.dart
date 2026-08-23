import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/batch_segmentation_provider.dart';

class BatchProgressDialog extends ConsumerWidget {
  const BatchProgressDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchSegmentationProvider);
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Traitement du dossier'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (state.isProcessing) ...[
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 16),
            Text(
              'Image ${state.current} sur ${state.total}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.currentImage ?? '',
              style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else if (state.error != null) ...[
            Icon(Icons.error_outline, color: scheme.error, size: 48),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ] else ...[
            Icon(Icons.check_circle_outline, color: scheme.tertiary, size: 48),
            const SizedBox(height: 16),
            Text('Traitement terminé ! ${state.successCount} images segmentées.'),
          ],
        ],
      ),
      actions: [
        if (!state.isProcessing)
          TextButton(
            onPressed: () {
              ref.read(batchSegmentationProvider.notifier).reset();
              Navigator.of(context).pop();
            },
            child: const Text('Fermer'),
          ),
      ],
    );
  }
}
