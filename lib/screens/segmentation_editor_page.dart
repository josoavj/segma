import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:segma/models/models.dart';
import 'package:segma/services/file_service.dart';

// Provider pour les objets segmentés en cours d'édition
final editorObjectsProvider = StateProvider<List<SegmentationResult>>((ref) {
  return [];
});

class SegmentationEditorPage extends ConsumerWidget {
  final ImageModel image;

  const SegmentationEditorPage({super.key, required this.image});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Panneau de contrôle gauche
        _buildLeftPanel(context, ref),

        // Image principale avec overlay
        Expanded(flex: 3, child: _buildImageViewer(context)),
      ],
    );
  }

  Widget _buildLeftPanel(BuildContext context, WidgetRef ref) {
    final objects = ref.watch(editorObjectsProvider);

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Révision des objets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ajustez les résultats avec des clics ou des boîtes.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher des objets...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),

          // Bouton Add object
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddObjectDialog(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un objet'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // Liste des objets
          Expanded(
            child: objects.isEmpty
                ? Center(
                    child: Text(
                      'Aucun objet pour le moment',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: objects.length,
                      itemBuilder: (context, index) {
                        final object = objects[index];
                        return _buildObjectItem(
                          context,
                          object: object,
                          index: index,
                          ref: ref,
                        );
                      },
                    ),
                  ),
          ),

          const Divider(height: 1),
        ],
      ),
    );
  }

  Future<void> _showAddObjectDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final confidence = ValueNotifier<double>(0.9);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un objet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'objet',
                hintText: 'ex: Voiture, Personne, Bâtiment...',
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<double>(
              valueListenable: confidence,
              builder: (context, value, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Confiance: ${(value * 100).toStringAsFixed(0)}%'),
                  Slider(
                    value: value,
                    onChanged: (newValue) => confidence.value = newValue,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () =>
                _addObject(context, ref, nameController.text, confidence.value),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _addObject(
    BuildContext context,
    WidgetRef ref,
    String name,
    double confidence,
  ) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nom d\'objet')),
      );
      return;
    }

    try {
      // Créer un masque fictif pour la démo (en pratique, ce serait un masque réel de SAM)
      final width = 512; // À adapter selon l'image
      final height = 512;
      final maskBytes = Uint8List(width * height);

      // Remplir avec des valeurs aléatoires pour la démo
      for (int i = 0; i < maskBytes.length; i++) {
        maskBytes[i] = (i % 2) * 255;
      }

      // Sauvegarder le masque localement
      await FileService.saveMask(image.path, maskBytes, name);

      // Créer l'objet segmenté
      final result = SegmentationResult(
        imageId: image.id,
        imagePath: image.path,
        width: width,
        height: height,
        objects: [],
        segmentationDir: '',
        createdAt: DateTime.now(),
      );

      // Ajouter à la liste locale
      final currentObjects = ref.read(editorObjectsProvider);
      ref.read(editorObjectsProvider.notifier).state = [
        ...currentObjects,
        result,
      ];

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Objet "$name" ajouté avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur lors de l\'ajout: $e')));
    }
  }

  Widget _buildObjectItem(
    BuildContext context, {
    required SegmentationResult object,
    required int index,
    required WidgetRef ref,
  }) {
    final objectName = object.imagePath.split('/').last.split('.').first;
    final color = _getColorForIndex(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Label et info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    objectName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(color == Colors.red
                            ? 100
                            : color == Colors.green
                            ? 95
                            : 90).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  final objects = ref.read(editorObjectsProvider);
                  final updated = objects.toList();
                  updated.removeAt(index);
                  ref.read(editorObjectsProvider.notifier).state = updated;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
              child: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.orange,
      Colors.cyan,
      Colors.pink,
      Colors.green,
      Colors.purple,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  Widget _buildImageViewer(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Stack(
        children: [
          // Image
          Positioned.fill(
            child: Image.file(
              File(image.path),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Image non trouvée',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Settings button (top right)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // TODO: Ouvrir settings
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
