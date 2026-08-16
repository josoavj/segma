import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:segma/models/models.dart';

/// Structure pour passer les données à l'Isolate
class _MaskParams {
  final SegmentationResult segmentation;
  final String imagePath;

  _MaskParams(this.segmentation, this.imagePath);
}

/// Fonction Top-level exécutée dans un Isolate séparé pour ne pas bloquer l'UI
Future<Uint8List> _generateMaskImageIsolated(_MaskParams params) async {
  try {
    final segmentation = params.segmentation;
    
    // Créer une image avec dimensions correctes
    final mask = img.Image(
      width: segmentation.width,
      height: segmentation.height,
      numChannels: 4,
    );

    // Initialiser tous les pixels en transparent
    for (int y = 0; y < segmentation.height; y++) {
      for (int x = 0; x < segmentation.width; x++) {
        mask.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }

    // Charger et appliquer chaque masque d'objet
    if (segmentation.objects.isNotEmpty) {
      for (final obj in segmentation.objects) {
        try {
          final maskFile = File(obj.maskPath);
          if (!maskFile.existsSync()) continue;

          final maskBytes = maskFile.readAsBytesSync();

          if (maskBytes.length != segmentation.width * segmentation.height) continue;

          for (int y = 0; y < segmentation.height; y++) {
            for (int x = 0; x < segmentation.width; x++) {
              final idx = y * segmentation.width + x;
              if (maskBytes[idx] > 128) {
                // Pixel du masque : Bleu semi-transparent
                mask.setPixelRgba(x, y, 100, 150, 255, 180);
              }
            }
          }
        } catch (e) {
          // Erreur silencieuse dans l'isolate
        }
      }
    }

    return Uint8List.fromList(img.encodePng(mask));
  } catch (e) {
    return Uint8List(0);
  }
}

class MaskOverlay extends StatelessWidget {
  final SegmentationResult segmentation;
  final String imagePath;

  const MaskOverlay({
    super.key,
    required this.segmentation,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      // Utilisation de compute() pour déporter le calcul dans un autre thread
      future: compute(_generateMaskImageIsolated, _MaskParams(segmentation, imagePath)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: Image.memory(
            snapshot.data!,
            fit: BoxFit.contain,
            color: Colors.blue.withValues(alpha: 0.1),
            colorBlendMode: BlendMode.screen,
            gaplessPlayback: true,
          ),
        );
      },
    );
  }
}
