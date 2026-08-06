import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/utils/ui_utils.dart';
import 'package:segma/widgets/common/modern_card.dart';

final segmentationSortProvider = StateProvider<String>((ref) => 'recent');

class SegmentedObjectsPage extends ConsumerWidget {
  const SegmentedObjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final segmentationHistory = ref.watch(segmentationHistoryProvider);
    final sortBy = ref.watch(segmentationSortProvider);

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

    return Column(
      children: [
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
                    const PopupMenuItem(value: 'recent', child: Text('Plus récent')),
                    const PopupMenuItem(value: 'confidence', child: Text('Par confiance')),
                    const PopupMenuItem(value: 'name', child: Text('Par nom')),
                  ],
                  color: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.sort, color: scheme.onPrimaryContainer),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: segmentationHistory.isEmpty
              ? const _EmptySegmentationState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedHistory.length,
                  itemBuilder: (context, index) {
                    return _SegmentationCard(segmentation: sortedHistory[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptySegmentationState extends StatelessWidget {
  const _EmptySegmentationState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.layers, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun objet segmenté',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cliquez sur une image pour commencer\nla segmentation',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fileName = segmentation.imagePath.split('/').last;
    
    final totalPixels = segmentation.objects.fold(0, (sum, obj) => sum + obj.pixelsCount);
    final maskSizeStr = UIUtils.formatFileSize(totalPixels * 4.0);
    
    final aspectRatio = segmentation.height > 0 ? segmentation.width / segmentation.height : 1.0;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.lerp(scheme.surfaceContainer, scheme.primary, 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: scheme.onPrimaryContainer,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color.lerp(
                              scheme.surfaceContainerHighest,
                              scheme.primary,
                              0.18,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            segmentation.objects.isNotEmpty
                                ? '${(segmentation.objects.first.confidence * 100).toStringAsFixed(1)}%'
                                : '0%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${segmentation.width}×${segmentation.height}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: isDark ? 0.62 : 0.4),
              borderRadius: BorderRadius.circular(8),
              border: isDark 
                  ? null 
                  : Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                DetailRow(
                  label: 'Dimensions',
                  value: '${segmentation.width} × ${segmentation.height} px',
                ),
                const Divider(height: 12),
                DetailRow(
                  label: 'Aspect ratio',
                  value: aspectRatio.toStringAsFixed(2),
                ),
                const Divider(height: 12),
                DetailRow(label: 'Masque', value: maskSizeStr),
                const Divider(height: 12),
                DetailRow(
                  label: 'Date',
                  value: UIUtils.formatDate(segmentation.createdAt),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Télécharger'),
                  style: FilledButton.styleFrom(
                    backgroundColor: scheme.primaryContainer,
                    foregroundColor: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.copy),
                  label: const Text('Copier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.primary,
                    side: BorderSide(color: scheme.primary.withValues(alpha: 0.35)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.35)),
                ),
                child: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
