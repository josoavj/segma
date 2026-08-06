import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/screens/segmentation_editor_page.dart';

class ImageViewerSidebar extends ConsumerWidget {
  final ImageModel image;
  final TextEditingController promptController;
  final TextEditingController searchController;
  final VoidCallback onSegment;
  final bool isLoading;
  final SegmentationResult? currentSeg;

  const ImageViewerSidebar({
    super.key,
    required this.image,
    required this.promptController,
    required this.searchController,
    required this.onSegment,
    required this.isLoading,
    this.currentSeg,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          right: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // En-tête du panneau
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: scheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Segmentation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section du prompt
                  _buildSectionTitle(context, 'Prompt'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: promptController,
                    minLines: 3,
                    maxLines: 5,
                    style: TextStyle(fontSize: 13, color: scheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Exemple: "person", "car", "all objects"',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 0, 16),
                        child: Icon(
                          Icons.edit_note,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Bouton segmenter
                  _buildSegmentButton(context),
                  const SizedBox(height: 12),
                  // Bouton Éditeur Interactif
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SegmentationEditorPage(image: image),
                        ),
                      );
                    },
                    icon: const Icon(Icons.touch_app),
                    label: const Text('Éditeur Interactif'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.primary,
                      side: BorderSide(
                        color: scheme.primary.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Séparateur
                  Divider(color: scheme.outlineVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 24),
                  // Section des objets détectés
                  _buildSectionTitle(context, 'Résultats'),
                  const SizedBox(height: 10),
                  // Champ de recherche
                  if (currentSeg != null && currentSeg!.objects.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Filtrer les objets...',
                          prefixIcon: Icon(
                            Icons.filter_list,
                            color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                            size: 18,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  // Liste des objets
                  _buildObjectsList(context, scheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: isLoading
            ? LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.5),
                  scheme.secondary.withValues(alpha: 0.5),
                ],
              )
            : LinearGradient(
                colors: [scheme.primary, scheme.primary.withValues(alpha: 0.85)],
              ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onSegment,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
                    ),
                  )
                else
                  Icon(Icons.search, color: scheme.onPrimary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Segmenter',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObjectsList(BuildContext context, ColorScheme scheme) {
    if (currentSeg != null && currentSeg!.objects.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        constraints: const BoxConstraints(maxHeight: 300),
        child: ListenableBuilder(
          listenable: searchController,
          builder: (context, _) {
            final filteredObjects = currentSeg!.objects
                .where(
                  (obj) => obj.label.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ),
                )
                .toList();

            return ListView.builder(
              shrinkWrap: true,
              itemCount: filteredObjects.length,
              itemBuilder: (context, index) {
                final object = filteredObjects[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary.withValues(alpha: 0.2),
                            scheme.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${object.objectId}',
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      object.label,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${(object.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                    trailing: Icon(
                      Icons.check_circle,
                      color: scheme.tertiary.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    } else if (currentSeg == null && !isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Lancez une segmentation\npour voir les résultats',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    } else if (currentSeg != null && currentSeg!.objects.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'Aucun objet détecté',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
