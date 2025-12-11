import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';

class SegmentedObjectsPage extends ConsumerWidget {
  const SegmentedObjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segmentationHistory = ref.watch(segmentationHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Objets Segmentés'), elevation: 0),
      body: segmentationHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.layers, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun objet segmenté pour le moment',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cliquez sur une image pour commencer',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: segmentationHistory.length,
              itemBuilder: (context, index) {
                final segmentation = segmentationHistory[index];
                return _SegmentationCard(segmentation: segmentation);
              },
            ),
    );
  }
}

class _SegmentationCard extends StatelessWidget {
  final SegmentationResult segmentation;

  const _SegmentationCard({required this.segmentation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Objet segmenté',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        segmentation.imagePath.split('/').last,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    '${(segmentation.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.blue.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dimensions',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${segmentation.width} × ${segmentation.height}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taille du masque',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(segmentation.maskData.length / 1024).toStringAsFixed(2)} KB',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${segmentation.createdAt.day}/${segmentation.createdAt.month}/${segmentation.createdAt.year} '
                        '${segmentation.createdAt.hour}:${segmentation.createdAt.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Téléchargement du masque...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Masque copié dans le presse-papiers'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copier'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
