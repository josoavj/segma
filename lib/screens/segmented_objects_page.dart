import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';

final segmentationSortProvider = StateProvider<String>((ref) => 'recent');

class SegmentedObjectsPage extends ConsumerWidget {
  const SegmentedObjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final segmentationHistory = ref.watch(segmentationHistoryProvider);
    final sortBy = ref.watch(segmentationSortProvider);

    // Sort the history
    final sortedHistory = List<SegmentationResult>.from(segmentationHistory);
    if (sortBy == 'recent') {
      sortedHistory.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (sortBy == 'confidence') {
      sortedHistory.sort(
        (a, b) => b.objects.isNotEmpty && a.objects.isNotEmpty
            ? b.objects.first.confidence.compareTo(a.objects.first.confidence)
            : 0,
      );
    } else if (sortBy == 'name') {
      sortedHistory.sort(
        (a, b) =>
            a.imagePath.split('/').last.compareTo(b.imagePath.split('/').last),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Sort and Filter Bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${segmentationHistory.length} objet${segmentationHistory.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (segmentationHistory.isNotEmpty)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      ref.read(segmentationSortProvider.notifier).state = value;
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'recent',
                        child: Text('Plus récent'),
                      ),
                      const PopupMenuItem(
                        value: 'confidence',
                        child: Text('Par confiance'),
                      ),
                      const PopupMenuItem(
                        value: 'name',
                        child: Text('Par nom'),
                      ),
                    ],
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sort, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: segmentationHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.layers,
                            size: 64,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun objet segmenté',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliquez sur une image pour commencer\nla segmentation',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedHistory.length,
                    itemBuilder: (context, index) {
                      final segmentation = sortedHistory[index];
                      return _SegmentationCard(segmentation: segmentation);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SegmentationCard extends StatelessWidget {
  final SegmentationResult segmentation;

  const _SegmentationCard({required this.segmentation});

  @override
  Widget build(BuildContext context) {
    final fileName = segmentation.imagePath.split('/').last;
    final fileSize = segmentation.objects.isNotEmpty
        ? (segmentation.objects.fold(
                    0,
                    (int sum, obj) => sum + obj.pixelsCount,
                  ) *
                  4 /
                  1024)
              .toStringAsFixed(2)
        : '0';
    final aspectRatio = segmentation.width / segmentation.height;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.purple[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                segmentation.objects.isNotEmpty
                                    ? '${(segmentation.objects.first.confidence * 100).toStringAsFixed(1)}%'
                                    : '0%',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.purple[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${segmentation.width}×${segmentation.height}',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Dimensions',
                      value:
                          '${segmentation.width} × ${segmentation.height} px',
                    ),
                    const Divider(height: 12),
                    _DetailRow(
                      label: 'Aspect ratio',
                      value: aspectRatio.toStringAsFixed(2),
                    ),
                    const Divider(height: 12),
                    _DetailRow(label: 'Masque', value: '$fileSize KB'),
                    const Divider(height: 12),
                    _DetailRow(
                      label: 'Date',
                      value:
                          '${segmentation.createdAt.day.toString().padLeft(2, '0')}/${segmentation.createdAt.month.toString().padLeft(2, '0')}/${segmentation.createdAt.year} '
                          '${segmentation.createdAt.hour.toString().padLeft(2, '0')}:${segmentation.createdAt.minute.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Téléchargement du masque...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Télécharger'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Masque copié dans le presse-papiers',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copier'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Objet supprimé')),
                      );
                    },
                    child: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }
}
