import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';

/// Écran complet pour la visualisation d'image avec segmentation (interface moderne)
class ImageViewerScreen extends StatelessWidget {
  final ImageModel image;

  const ImageViewerScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ImageViewerWidget(image: image));
  }
}

class ImageViewerWidget extends ConsumerStatefulWidget {
  final ImageModel image;

  const ImageViewerWidget({super.key, required this.image});

  @override
  ConsumerState<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends ConsumerState<ImageViewerWidget> {
  bool _showMask = false;
  late Size _imageSize;
  bool _imageSizeLoaded = false;
  late TextEditingController _searchController;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _promptController = TextEditingController(text: 'all objects in the image');
    _loadImageSize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadImageSize() async {
    try {
      final file = File(widget.image.path);
      if (await file.exists()) {
        final imageBytes = await file.readAsBytes();
        final image = img.decodeImage(imageBytes);
        if (image != null) {
          setState(() {
            _imageSize = Size(image.width.toDouble(), image.height.toDouble());
            _imageSizeLoaded = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de la taille de l\'image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(segmentationLoadingProvider);
    final error = ref.watch(segmentationErrorProvider);
    final currentSeg = ref.watch(currentSegmentationProvider);

    // Lancer la segmentation automatiquement si pas encore faite
    ref.listen(currentSegmentationProvider, (previous, next) {});

    // Déclencher la segmentation automatiquement au montage
    if (currentSeg == null && !isLoading) {
      Future.microtask(() {
        ref
            .read(segmentImageProvider.notifier)
            .segment(widget.image.path)
            .then((_) {
              // Segmentation réussie
            })
            .catchError((e) {
              debugPrint('Erreur segmentation: $e');
            });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.image.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.image.path,
              style: const TextStyle(color: Colors.white38, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Row(
        children: [
          // Panneau latéral gauche : contrôles
          Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.blue,
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
                          controller: _promptController,
                          minLines: 3,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
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
                        Container(
                          decoration: BoxDecoration(
                            gradient: isLoading
                                ? LinearGradient(
                                    colors: [
                                      Colors.blue.withValues(alpha: 0.5),
                                      Colors.cyan.withValues(alpha: 0.5),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.blue.shade600,
                                      Colors.blue.shade700,
                                    ],
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
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      ref
                                          .read(
                                            segmentationPromptProvider.notifier,
                                          )
                                          .state = _promptController
                                          .text;

                                      ref
                                              .read(
                                                segmentationErrorProvider
                                                    .notifier,
                                              )
                                              .state =
                                          null;

                                      await ref
                                          .read(segmentImageProvider.notifier)
                                          .segment(widget.image.path)
                                          .then((_) {})
                                          .catchError((e) {
                                            debugPrint(
                                              'Erreur segmentation: $e',
                                            );
                                          });
                                    },
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isLoading)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 20,
                                      ),
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
                        if (currentSeg != null && currentSeg.objects.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextField(
                              controller: _searchController,
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
                                  borderSide: const BorderSide(
                                    color: Colors.blue,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.03),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        // Liste des objets
                        if (currentSeg != null && currentSeg.objects.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: currentSeg.objects.length,
                              itemBuilder: (context, index) {
                                final object = currentSeg.objects[index];
                                final isMatch = object.label
                                    .toLowerCase()
                                    .contains(
                                      _searchController.text.toLowerCase(),
                                    );

                                if (!isMatch) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
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
                                          color: Colors.blue.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${object.objectId}',
                                          style: const TextStyle(
                                            color: Colors.blue,
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
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.check_circle,
                                      color: Colors.green.withValues(
                                        alpha: 0.7,
                                      ),
                                      size: 16,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        else if (currentSeg == null && !isLoading)
                          Container(
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
                          )
                        else if (currentSeg != null &&
                            currentSeg.objects.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Aucun objet détecté',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Partie principale : image et résultats
          Expanded(
            child: Container(
              color: const Color(0xFF0F0F0F),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image originale
                  Center(
                    child: Image.file(
                      File(widget.image.path),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.white.withValues(alpha: 0.3),
                                size: 56,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur lors du chargement',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Overlay du masque
                  if (_showMask && currentSeg != null)
                    _MaskOverlayWidget(
                      segmentation: currentSeg,
                      imagePath: widget.image.path,
                    ),
                  // Overlay des bounding boxes
                  if (currentSeg != null && currentSeg.objects.isNotEmpty)
                    _BoundingBoxesOverlayWidget(
                      segmentation: currentSeg,
                      imageSize: _imageSizeLoaded ? _imageSize : Size.zero,
                    ),
                  // Bouton basculer masque
                  if (currentSeg != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _showMask ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white70,
                            size: 20,
                          ),
                          tooltip: _showMask
                              ? 'Masquer le masque'
                              : 'Afficher le masque',
                          onPressed: () {
                            setState(() => _showMask = !_showMask);
                          },
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  // Indicateur de chargement
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      ),
                    ),
                  // Message d'erreur
                  if (error != null)
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Erreur de segmentation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              error,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

class _MaskOverlayWidget extends StatelessWidget {
  final SegmentationResult segmentation;
  final String imagePath;

  const _MaskOverlayWidget({
    required this.segmentation,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _generateMaskImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.contain,
          color: Colors.blue.withValues(alpha: 0.4),
          colorBlendMode: BlendMode.screen,
        );
      },
    );
  }

  Future<Uint8List> _generateMaskImage() async {
    try {
      final mask = img.Image(
        width: segmentation.width,
        height: segmentation.height,
        numChannels: 4,
      );

      if (segmentation.objects.isNotEmpty) {
        final maskBytes = List<int>.filled(
          segmentation.width * segmentation.height,
          0,
        );

        for (int y = 0; y < segmentation.height; y++) {
          for (int x = 0; x < segmentation.width; x++) {
            final index = y * segmentation.width + x;
            if (index < maskBytes.length) {
              final value = maskBytes[index];
              if (value > 128) {
                mask.setPixelRgba(x, y, 0, 100, 255, 150);
              }
            }
          }
        }
      }

      return Uint8List.fromList(img.encodePng(mask));
    } catch (e) {
      debugPrint('Erreur lors de la génération du masque: $e');
      return Uint8List(0);
    }
  }
}

class _BoundingBoxesOverlayWidget extends StatelessWidget {
  final SegmentationResult segmentation;
  final Size imageSize;

  const _BoundingBoxesOverlayWidget({
    required this.segmentation,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: BoundingBoxesPainter(
          objects: segmentation.objects,
          imageSize: imageSize,
          imageWidth: segmentation.width,
          imageHeight: segmentation.height,
        ),
      ),
    );
  }
}

class BoundingBoxesPainter extends CustomPainter {
  final List<SegmentedObject> objects;
  final Size imageSize;
  final int imageWidth;
  final int imageHeight;

  BoundingBoxesPainter({
    required this.objects,
    required this.imageSize,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imageAspectRatio = imageWidth / imageHeight;
    final canvasAspectRatio = size.width / size.height;

    late double scaleX;
    late double scaleY;
    late double offsetX;
    late double offsetY;

    if (imageAspectRatio > canvasAspectRatio) {
      scaleX = size.width / imageWidth;
      scaleY = scaleX;
      offsetX = 0;
      offsetY = (size.height - imageHeight * scaleY) / 2;
    } else {
      scaleY = size.height / imageHeight;
      scaleX = scaleY;
      offsetY = 0;
      offsetX = (size.width - imageWidth * scaleX) / 2;
    }

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final object in objects) {
      final bbox = object.bbox;

      final x1 = bbox.x1.toDouble();
      final y1 = bbox.y1.toDouble();
      final x2 = bbox.x2.toDouble();
      final y2 = bbox.y2.toDouble();

      final canvasX1 = offsetX + x1 * scaleX;
      final canvasY1 = offsetY + y1 * scaleY;
      final canvasX2 = offsetX + x2 * scaleX;
      final canvasY2 = offsetY + y2 * scaleY;

      canvas.drawRect(
        Rect.fromLTRB(canvasX1, canvasY1, canvasX2, canvasY2),
        borderPaint,
      );

      final label =
          '${object.label} (${(object.confidence * 100).toStringAsFixed(0)}%)';

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final labelX = canvasX1;
      final labelY = canvasY1 - textPainter.height - 4;

      canvas.drawRect(
        Rect.fromLTWH(
          labelX - 4,
          labelY,
          textPainter.width + 8,
          textPainter.height + 4,
        ),
        bgPaint,
      );

      textPainter.paint(canvas, Offset(labelX, labelY + 2));
    }
  }

  @override
  bool shouldRepaint(BoundingBoxesPainter oldDelegate) {
    return objects.length != oldDelegate.objects.length ||
        imageSize != oldDelegate.imageSize;
  }
}
