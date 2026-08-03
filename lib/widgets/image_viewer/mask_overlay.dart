import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:segma/models/models.dart';

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
      // Créer une image avec dimensions correctes
      final mask = img.Image(
        width: segmentation.width,
        height: segmentation.height,
        numChannels: 4,
      );

      // Initialiser tous les pixels en transparent (remplir la toile)
      for (int y = 0; y < segmentation.height; y++) {
        for (int x = 0; x < segmentation.width; x++) {
          mask.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }

      // Charger et appliquer chaque masque d'objet
      if (segmentation.objects.isNotEmpty) {
        for (final obj in segmentation.objects) {
          try {
            // Charger le fichier masque binaire
            final maskFile = File(obj.maskPath);
            if (!await maskFile.exists()) {
              debugPrint('Fichier masque non trouvé: ${obj.maskPath}');
              continue;
            }

            final maskBytes = await maskFile.readAsBytes();

            // Vérifier que la taille correspond
            if (maskBytes.length != segmentation.width * segmentation.height) {
              debugPrint(
                'Erreur: taille du masque incorrecte (${maskBytes.length} != ${segmentation.width * segmentation.height})',
              );
              continue;
            }

            // Appliquer le masque à l'image (blanc là où il y a du masque)
            for (int y = 0; y < segmentation.height; y++) {
              for (int x = 0; x < segmentation.width; x++) {
                final idx = y * segmentation.width + x;
                if (maskBytes[idx] > 128) {
                  // Pixel du masque: afficher en couleur semi-transparente
                  mask.setPixelRgba(x, y, 100, 150, 255, 180);
                }
              }
            }
          } catch (e) {
            debugPrint('Erreur chargement masque ${obj.objectId}: $e');
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
