import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadImageSize();
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

  void _handleImageTap(TapDownDetails details) {
    if (!_imageSizeLoaded) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);

    // Calculer le ratio de l'image dans le conteneur
    final containerSize = box.size;
    final imageRatio = _imageSize.width / _imageSize.height;
    final containerRatio = containerSize.width / containerSize.height;

    double imageDisplayWidth, imageDisplayHeight, offsetX, offsetY;

    if (imageRatio > containerRatio) {
      // Image plus large que haute
      imageDisplayWidth = containerSize.width;
      imageDisplayHeight = containerSize.width / imageRatio;
      offsetX = 0;
      offsetY = (containerSize.height - imageDisplayHeight) / 2;
    } else {
      // Image plus haute que large
      imageDisplayHeight = containerSize.height;
      imageDisplayWidth = containerSize.height * imageRatio;
      offsetX = (containerSize.width - imageDisplayWidth) / 2;
      offsetY = 0;
    }

    // Vérifier si le clic est sur l'image
    final dx = localPosition.dx;
    final dy = localPosition.dy;

    if (dx >= offsetX &&
        dx <= offsetX + imageDisplayWidth &&
        dy >= offsetY &&
        dy <= offsetY + imageDisplayHeight) {
      // Convertir les coordonnées du clic en coordonnées de l'image
      final relX = (dx - offsetX) / imageDisplayWidth;
      final relY = (dy - offsetY) / imageDisplayHeight;

      final imageX = (relX * _imageSize.width).toInt();
      final imageY = (relY * _imageSize.height).toInt();

      debugPrint('Image cliquée à: ($imageX, $imageY)');

      // Créer la requête de segmentation
      final request = SegmentationRequest(
        imagePath: widget.image.path,
        x: imageX,
        y: imageY,
      );

      // Lancer la segmentation
      ref.read(segmentationProvider(request));
      setState(() => _showMask = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(segmentationLoadingProvider);
    final error = ref.watch(segmentationErrorProvider);
    final currentSeg = ref.watch(currentSegmentationProvider);

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // Barre d'infos
          Container(
            color: Colors.grey[800],
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.image.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.image.path,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Afficheur d'image
          Expanded(
            child: GestureDetector(
              onTapDown: _handleImageTap,
              child: Container(
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image originale
                    Image.file(
                      File(widget.image.path),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur lors du chargement de l\'image',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    // Overlay du masque
                    if (_showMask && currentSeg != null)
                      _MaskOverlayWidget(
                        segmentation: currentSeg,
                        imagePath: widget.image.path,
                      ),
                    // Bouton basculer masque
                    if (currentSeg != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(
                            _showMask ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          tooltip: _showMask
                              ? 'Masquer le masque'
                              : 'Afficher le masque',
                          onPressed: () {
                            setState(() => _showMask = !_showMask);
                          },
                        ),
                      ),
                    // Indicateur de chargement
                    if (isLoading)
                      Container(
                        color: Colors.black45,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.blue),
                          ),
                        ),
                      ),
                    // Message d'erreur
                    if (error != null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Erreur de segmentation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                error,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Instruction pour cliquer
                    if (!isLoading && currentSeg == null)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Text(
                            'Cliquez sur un objet pour le segmenter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
      // Créer une image de masque avec les dimensions correctes
      final mask = img.Image(
        width: segmentation.width,
        height: segmentation.height,
        numChannels: 4,
      );

      // Remplir avec les données du masque
      final maskBytes = segmentation.maskData;

      for (int y = 0; y < segmentation.height; y++) {
        for (int x = 0; x < segmentation.width; x++) {
          final index = y * segmentation.width + x;
          if (index < maskBytes.length) {
            final value = maskBytes[index];
            // Pixel bleu avec opacité basée sur la valeur du masque
            if (value > 128) {
              mask.setPixelRgba(x, y, 0, 100, 255, 150);
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
