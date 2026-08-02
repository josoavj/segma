import 'package:flutter_test/flutter_test.dart';
import 'package:segma/models/models.dart';

void main() {
  group('Segmentation Models Tests', () {
    test('BoundingBox.fromJson should parse correctly', () {
      final json = {'x1': 10, 'y1': 20, 'x2': 100, 'y2': 200};
      final bbox = BoundingBox.fromJson(json);
      
      expect(bbox.x1, 10);
      expect(bbox.y1, 20);
      expect(bbox.x2, 100);
      expect(bbox.y2, 200);
      expect(bbox.width, 90);
      expect(bbox.height, 180);
    });

    test('SegmentedObject.fromJson should parse correctly', () {
      final json = {
        'object_id': 1,
        'label': 'bolt',
        'confidence': 0.95,
        'bbox': {'x1': 10, 'y1': 10, 'x2': 50, 'y2': 50},
        'mask_path': '/path/to/mask.bin',
        'pixels_count': 1600
      };
      
      final obj = SegmentedObject.fromJson(json);
      
      expect(obj.objectId, 1);
      expect(obj.label, 'bolt');
      expect(obj.confidence, 0.95);
      expect(obj.maskPath, '/path/to/mask.bin');
      expect(obj.pixelsCount, 1600);
    });

    test('SegmentationResult.fromJson should handle resolution and objects', () {
      final json = {
        'image_path': '/test/image.jpg',
        'resolution': '1920x1080',
        'segmentation_dir': '/test/seg_dir',
        'objects': [
          {
            'object_id': 0,
            'label': 'nut',
            'confidence': 0.88,
            'bbox': {'x1': 0, 'y1': 0, 'x2': 10, 'y2': 10},
            'mask_path': 'm0.bin',
            'pixels_count': 100
          }
        ]
      };

      final result = SegmentationResult.fromJson(json);

      expect(result.imagePath, '/test/image.jpg');
      expect(result.width, 1920);
      expect(result.height, 1080);
      expect(result.objects.length, 1);
      expect(result.objects.first.label, 'nut');
      expect(result.segmentationDir, '/test/seg_dir');
    });
  });

  group('Interaction Models Tests', () {
    test('InteractivePoint.toJson should return correct format', () {
      const point = InteractivePoint(x: 0.5, y: 0.5, isPositive: true);
      final json = point.toJson();
      
      expect(json['x'], 0.5);
      expect(json['y'], 0.5);
      expect(json['label'], 1);
    });
    
    test('InteractivePoint negative should have label 0', () {
      const point = InteractivePoint(x: 0.1, y: 0.2, isPositive: false);
      expect(point.toJson()['label'], 0);
    });
  });
}
