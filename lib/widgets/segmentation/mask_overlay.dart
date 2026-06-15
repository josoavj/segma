import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:segma/models/models.dart';

class MaskOverlay extends StatelessWidget {
  final SegmentationResult segmentation;

  const MaskOverlay({
    super.key,
    required this.segmentation,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _generateMaskImage(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
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

      for (int y = 0; y < segmentation.height; y++) {
        for (int x = 0; x < segmentation.width; x++) {
          mask.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }

      for (final object in segmentation.objects) {
        await _paintObjectMask(mask, object);
      }

      return Uint8List.fromList(img.encodePng(mask));
    } catch (e) {
      debugPrint('Erreur lors de la génération du masque: $e');
      return Uint8List(0);
    }
  }

  Future<void> _paintObjectMask(img.Image canvas, SegmentedObject object) async {
    try {
      final maskFile = File(object.maskPath);
      if (!await maskFile.exists()) {
        debugPrint('Fichier masque non trouvé: ${object.maskPath}');
        return;
      }

      final maskBytes = await maskFile.readAsBytes();
      final expectedLength = segmentation.width * segmentation.height;
      if (maskBytes.length != expectedLength) {
        debugPrint(
          'Erreur: taille du masque incorrecte '
          '(${maskBytes.length} != $expectedLength)',
        );
        return;
      }

      for (int y = 0; y < segmentation.height; y++) {
        for (int x = 0; x < segmentation.width; x++) {
          final idx = y * segmentation.width + x;
          if (maskBytes[idx] > 128) {
            canvas.setPixelRgba(x, y, 100, 150, 255, 180);
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur chargement masque ${object.objectId}: $e');
    }
  }
}
