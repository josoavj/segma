import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';

class SegmentationEditorPage extends ConsumerStatefulWidget {
  final ImageModel image;

  const SegmentationEditorPage({super.key, required this.image});

  @override
  ConsumerState<SegmentationEditorPage> createState() => _SegmentationEditorPageState();
}

class _SegmentationEditorPageState extends ConsumerState<SegmentationEditorPage> {
  final GlobalKey _imageKey = GlobalKey();
  bool _isPositiveMode = true;

  @override
  void initState() {
    super.initState();
    // Réinitialiser les points au démarrage de l'éditeur
    Future.microtask(() {
      ref.read(interactivePointsProvider.notifier).state = [];
      ref.read(currentSegmentationProvider.notifier).state = null;
    });
  }

  void _handleTap(TapUpDetails details, Size size) {
    final RenderBox renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // Normalisation des coordonnées entre 0 et 1 pour une compatibilité totale
    final xNorm = localPosition.dx / size.width;
    final yNorm = localPosition.dy / size.height;

    if (xNorm >= 0 && xNorm <= 1 && yNorm >= 0 && yNorm <= 1) {
      final point = InteractivePoint(
        x: xNorm,
        y: yNorm,
        isPositive: _isPositiveMode,
      );

      final currentPoints = ref.read(interactivePointsProvider);
      ref.read(interactivePointsProvider.notifier).state = [...currentPoints, point];

      _triggerSegmentation();
    }
  }

  Future<void> _triggerSegmentation() async {
    await ref.read(segmentImageProvider.notifier).segment(widget.image.path);
  }

  void _clearPoints() {
    ref.read(interactivePointsProvider.notifier).state = [];
    ref.read(currentSegmentationProvider.notifier).state = null;
  }

  void _undoPoint() {
    final points = ref.read(interactivePointsProvider);
    if (points.isNotEmpty) {
      ref.read(interactivePointsProvider.notifier).state = points.sublist(0, points.length - 1);
      if (ref.read(interactivePointsProvider).isEmpty) {
        ref.read(currentSegmentationProvider.notifier).state = null;
      } else {
        _triggerSegmentation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Édition : ${widget.image.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(),
          ),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Container(
              color: Colors.black,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTapUp: (details) => _handleTap(details, _getImageWidgetSize()),
                          child: Stack(
                            children: [
                              Image.file(
                                File(widget.image.path),
                                key: _imageKey,
                                fit: BoxFit.contain,
                              ),
                              
                              // Overlay des points d'interaction (re-calculés selon la taille réelle)
                              Consumer(
                                builder: (context, ref, child) {
                                  final points = ref.watch(interactivePointsProvider);
                                  final imgSize = _getImageWidgetSize();
                                  if (imgSize == Size.zero) return const SizedBox.shrink();

                                  return Stack(
                                    children: points.map((p) => Positioned(
                                      left: p.x * imgSize.width - 6,
                                      top: p.y * imgSize.height - 6,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: p.isPositive ? Colors.blue : Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                                        ),
                                      ),
                                    )).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildFloatingToolbar(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Size _getImageWidgetSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox.size;
    }
    return Size.zero;
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide à la segmentation'),
        content: const Text(
          '• Inclusion (Bleu) : Cliquez sur l\'objet que vous voulez détourer.\n'
          '• Exclusion (Rouge) : Cliquez sur les zones à supprimer du masque.\n'
          '• SAM recalcule automatiquement le masque après chaque clic.',
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Compris'))],
      ),
    );
  }

  Widget _buildSidebar() {
    final isLoading = ref.watch(segmentationLoadingProvider);
    final result = ref.watch(currentSegmentationProvider);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Objets Détectés', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${result?.objects.length ?? 0} segments trouvés', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: result == null 
              ? _buildInstructions()
              : _buildObjectList(result),
          ),
          if (isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: result != null ? () => Navigator.pop(context, result) : null,
              icon: const Icon(Icons.check),
              label: const Text('Valider l\'édition'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mouse, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Commencez par cliquer sur l\'image pour définir l\'objet.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectList(SegmentationResult result) {
    return ListView.builder(
      itemCount: result.objects.length,
      itemBuilder: (context, index) {
        final obj = result.objects[index];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue.withValues(alpha: 0.2),
            child: Text('${index + 1}', style: const TextStyle(fontSize: 10)),
          ),
          title: Text(obj.label),
          subtitle: Text('${(obj.confidence * 100).toStringAsFixed(1)}% confiance'),
        );
      },
    );
  }

  Widget _buildFloatingToolbar() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withValues(alpha: 0.3))],
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _modeToggle(
                icon: Icons.add_circle,
                label: 'Inclure',
                isSelected: _isPositiveMode,
                color: Colors.blue,
                onTap: () => setState(() => _isPositiveMode = true),
              ),
              const SizedBox(width: 12),
              _modeToggle(
                icon: Icons.remove_circle,
                label: 'Exclure',
                isSelected: !_isPositiveMode,
                color: Colors.red,
                onTap: () => setState(() => _isPositiveMode = false),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: VerticalDivider(width: 20, thickness: 1),
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _undoPoint,
                tooltip: 'Annuler',
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep),
                onPressed: _clearPoints,
                tooltip: 'Tout effacer',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeToggle({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
