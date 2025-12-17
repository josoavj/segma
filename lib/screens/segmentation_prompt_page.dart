import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/widgets/segmented_object_card.dart';

class SegmentationPage extends ConsumerStatefulWidget {
  final String imagePath;

  const SegmentationPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  ConsumerState<SegmentationPage> createState() => _SegmentationPageState();
}

class _SegmentationPageState extends ConsumerState<SegmentationPage> {
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(
      text: ref.read(segmentationPromptProvider),
    );
    // Lancer la segmentation automatiquement
    _performSegmentation();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _performSegmentation() async {
    // Mettre à jour le prompt depuis le contrôleur
    ref.read(segmentationPromptProvider.notifier).state =
        _promptController.text;

    // Lancer la segmentation avec le nouvel AsyncNotifier
    await ref.read(segmentImageProvider.notifier).segment(widget.imagePath);
  }

  void _updatePromptAndSegment() async {
    ref.read(segmentationPromptProvider.notifier).state =
        _promptController.text;
    await _performSegmentation();
  }

  void _toggleObjectSelection(int objectId) {
    final result = ref.read(currentSegmentationProvider);
    if (result != null) {
      final index = result.objects.indexWhere((o) => o.objectId == objectId);
      if (index >= 0) {
        result.objects[index].isSelected = !result.objects[index].isSelected;
        ref
            .read(currentSegmentationProvider.notifier)
            .state = SegmentationResult(
          imageId: result.imageId,
          imagePath: result.imagePath,
          width: result.width,
          height: result.height,
          objects: [...result.objects],
          segmentationDir: result.segmentationDir,
          createdAt: result.createdAt,
        );
      }
    }
  }

  void _selectAll() {
    final result = ref.read(currentSegmentationProvider);
    if (result != null) {
      for (var obj in result.objects) {
        obj.isSelected = true;
      }
      ref.read(currentSegmentationProvider.notifier).state = SegmentationResult(
        imageId: result.imageId,
        imagePath: result.imagePath,
        width: result.width,
        height: result.height,
        objects: [...result.objects],
        segmentationDir: result.segmentationDir,
        createdAt: result.createdAt,
      );
    }
  }

  void _deselectAll() {
    final result = ref.read(currentSegmentationProvider);
    if (result != null) {
      for (var obj in result.objects) {
        obj.isSelected = false;
      }
      ref.read(currentSegmentationProvider.notifier).state = SegmentationResult(
        imageId: result.imageId,
        imagePath: result.imagePath,
        width: result.width,
        height: result.height,
        objects: [...result.objects],
        segmentationDir: result.segmentationDir,
        createdAt: result.createdAt,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(segmentationLoadingProvider);
    final error = ref.watch(segmentationErrorProvider);
    final result = ref.watch(currentSegmentationProvider);

    return WillPopScope(
      onWillPop: () async {
        ref.invalidate(segmentationPromptProvider);
        ref.invalidate(confidenceThresholdProvider);
        ref.invalidate(currentSegmentationProvider);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Segmentation d\'image'),
          centerTitle: true,
          elevation: 0,
        ),
        body: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Segmentation en cours...'),
                  ],
                ),
              )
            : error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Erreur: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _performSegmentation,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
            : result == null
            ? const Center(child: Text('Aucun résultat'))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prompt input
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Modifier le prompt',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _promptController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Décrivez les objets à segmenter...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: _updatePromptAndSegment,
                                  ),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Objets détectés
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Objets détectés: ${result.objects.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (result.objects.isNotEmpty)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'select_all') {
                                  _selectAll();
                                } else if (value == 'deselect_all') {
                                  _deselectAll();
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'select_all',
                                  child: Text('Sélectionner tout'),
                                ),
                                const PopupMenuItem(
                                  value: 'deselect_all',
                                  child: Text('Désélectionner tout'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Liste des objets
                      if (result.objects.isEmpty)
                        const Center(
                          child: Text(
                            'Aucun objet détecté',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: result.objects.length,
                          itemBuilder: (context, index) {
                            final obj = result.objects[index];
                            return SegmentedObjectCard(
                              object: obj,
                              isSelected: obj.isSelected,
                              onTap: () => _toggleObjectSelection(obj.objectId),
                            );
                          },
                        ),
                      const SizedBox(height: 24),

                      // Boutons d'action
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: result.objects.any((obj) => obj.isSelected)
                              ? () {
                                  final selected = result.objects
                                      .where((obj) => obj.isSelected)
                                      .map((obj) => obj.objectId)
                                      .toList();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Objets sélectionnés: ${selected.join(", ")}',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  // Ici vous pouvez sauvegarder les masques
                                  Navigator.of(context).pop(selected);
                                }
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Enregistrer la sélection'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
