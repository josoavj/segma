import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:segma/features/home/models/image_model.dart';
import 'package:segma/features/segmentation/view_models/segmentation_view_model.dart';
import 'package:segma/features/home/view_models/home_view_model.dart';
import 'package:segma/features/segmentation/views/widgets/image_viewer_sidebar.dart';
import 'package:segma/features/segmentation/views/widgets/image_viewer_appbar.dart';
import 'package:segma/features/segmentation/views/widgets/mask_overlay.dart';
import 'package:segma/features/segmentation/views/widgets/bounding_boxes_overlay.dart';

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

    // Utilisation de microtask pour éviter l'erreur de modification pendant le build
    Future.microtask(() {
      if (mounted) {
        ref.read(segmentationPromptProvider.notifier).state =
            _promptController.text;
      }
    });

    _loadImageSize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _segmentCurrentImage();
    });
  }

  @override
  void didUpdateWidget(covariant ImageViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.path != widget.image.path) {
      _showMask = false;
      _imageSizeLoaded = false;
      ref.read(segmentImageProvider.notifier).reset();
      _loadImageSize();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _segmentCurrentImage();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadImageSize() async {
    final imagePath = widget.image.path;
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final imageBytes = await file.readAsBytes();
        final image = img.decodeImage(imageBytes);
        if (image != null && mounted && widget.image.path == imagePath) {
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

  void _segmentCurrentImage() {
    ref
        .read(segmentImageProvider.notifier)
        .segment(widget.image.path)
        .catchError((e) {
      debugPrint('Erreur segmentation automatique: $e');
    });
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
    final segmentState = ref.watch(segmentImageProvider);

    final currentSeg = segmentState.whenData((data) => data).value;

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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
