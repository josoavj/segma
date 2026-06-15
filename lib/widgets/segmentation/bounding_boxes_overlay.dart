import 'package:flutter/material.dart';
import 'package:segma/models/models.dart';

class BoundingBoxesOverlay extends StatelessWidget {
  final SegmentationResult segmentation;
  final Size imageSize;

  const BoundingBoxesOverlay({
    super.key,
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

      final canvasX1 = offsetX + bbox.x1 * scaleX;
      final canvasY1 = offsetY + bbox.y1 * scaleY;
      final canvasX2 = offsetX + bbox.x2 * scaleX;
      final canvasY2 = offsetY + bbox.y2 * scaleY;

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
