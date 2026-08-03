import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:segma/models/models.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/providers/file_provider.dart';
import 'package:segma/widgets/image_viewer/image_viewer_sidebar.dart';
import 'package:segma/widgets/image_viewer/image_viewer_appbar.dart';
import 'package:segma/widgets/image_viewer/mask_overlay.dart';
import 'package:segma/widgets/image_viewer/bounding_boxes_overlay.dart';

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
    ref.read(segmentationPromptProvider.notifier).state = _promptController.text;
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

  void _handleBackNavigation(BuildContext context) {
    ref.read(selectedImageProvider.notifier).state = null;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(segmentationLoadingProvider);
    final error = ref.watch(segmentationErrorProvider);
    final segmentState = ref.watch(segmentImageProvider);

    final currentSeg = segmentState.whenData((data) => data).value;

    if (currentSeg == null && !isLoading) {
      Future.microtask(() {
        ref
            .read(segmentImageProvider.notifier)
            .segment(widget.image.path)
            .catchError((e) {
              debugPrint('Erreur segmentation: $e');
            });
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: ImageViewerAppBar(
        image: widget.image,
        onBack: () => _handleBackNavigation(context),
      ),
      body: Row(
        children: [
          ImageViewerSidebar(
            image: widget.image,
            promptController: _promptController,
            searchController: _searchController,
            isLoading: isLoading,
            currentSeg: currentSeg,
            onSegment: () async {
              ref.read(segmentationPromptProvider.notifier).state =
                  _promptController.text;
              ref.read(segmentationErrorProvider.notifier).state = null;
              await ref
                  .read(segmentImageProvider.notifier)
                  .segment(widget.image.path)
                  .catchError((e) {
                    debugPrint('Erreur segmentation: $e');
                  });
            },
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF0F0F0F),
              child: Stack(
                fit: StackFit.expand,
                children: [
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
                  if (_showMask && currentSeg != null)
                    MaskOverlay(
                      segmentation: currentSeg,
                      imagePath: widget.image.path,
                    ),
                  if (currentSeg != null && currentSeg.objects.isNotEmpty)
                    BoundingBoxesOverlay(
                      segmentation: currentSeg,
                      imageSize: _imageSizeLoaded ? _imageSize : Size.zero,
                    ),
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
                  if (isLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                      ),
                    ),
                  if (error != null)
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: _ErrorMessage(error: error),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String error;
  const _ErrorMessage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
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
          Text(error, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
