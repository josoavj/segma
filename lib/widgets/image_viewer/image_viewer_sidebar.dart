import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';
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
        color: const Color(0xFF1A1A1A),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
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
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F4A8A).withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF8FD1FF),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Segmentation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
                  _buildSectionTitle('Prompt'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: promptController,
                    minLines: 3,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Exemple: "person", "car", "all objects"',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 0, 16),
                        child: Icon(
                          Icons.edit_note,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.03),
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
                      foregroundColor: Colors.blue[300],
                      side: BorderSide(
                        color: Colors.blue.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Séparateur
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Section des objets détectés
                  _buildSectionTitle('Résultats'),
                  const SizedBox(height: 10),
                  // Champ de recherche
                  if (currentSeg != null && currentSeg!.objects.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Filtrer les objets...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.filter_list,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.03),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
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
    return Container(
      decoration: BoxDecoration(
        gradient: isLoading
            ? LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.5),
                  Colors.cyan.withValues(alpha: 0.5),
                ],
              )
            : LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade700],
              ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
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
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                else
                  const Icon(Icons.search, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Segmenter',
                  style: TextStyle(
                    color: Colors.white,
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
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                        color: Colors.white.withValues(alpha: 0.05),
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
                            Colors.blue.withValues(alpha: 0.2),
                            Colors.cyan.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${object.objectId}',
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      object.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${(object.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
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
            color: Colors.white.withValues(alpha: 0.4),
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
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
