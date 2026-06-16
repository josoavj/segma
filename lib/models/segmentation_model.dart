/// Boîte englobante
class BoundingBox {
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  const BoundingBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  int get width => x2 - x1;
  int get height => y2 - y1;

  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x1: json['x1'] as int,
      y1: json['y1'] as int,
      x2: json['x2'] as int,
      y2: json['y2'] as int,
    );
  }
}

/// Objet segmenté détecté dans une image
class SegmentedObject {
  final int objectId;
  final String label;
  final double confidence;
  final BoundingBox bbox;
  final String maskPath;
  final int pixelsCount;
  bool isSelected;

  SegmentedObject({
    required this.objectId,
    required this.label,
    required this.confidence,
    required this.bbox,
    required this.maskPath,
    required this.pixelsCount,
    this.isSelected = false,
  });

  factory SegmentedObject.fromJson(Map<String, dynamic> json) {
    return SegmentedObject(
      objectId: json['object_id'] as int,
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      bbox: BoundingBox.fromJson(json['bbox'] as Map<String, dynamic>),
      maskPath: json['mask_path'] as String,
      pixelsCount: json['pixels_count'] as int,
    );
  }
}

/// Résultat de segmentation multi-objets
class SegmentationResult {
  final String imageId;
  final String imagePath;
  final int width;
  final int height;
  final List<SegmentedObject> objects;
  final String segmentationDir;
  final DateTime createdAt;

  const SegmentationResult({
    required this.imageId,
    required this.imagePath,
    required this.width,
    required this.height,
    required this.objects,
    required this.segmentationDir,
    required this.createdAt,
  });

  factory SegmentationResult.fromJson(Map<String, dynamic> json) {
    final resolution = json['resolution'] as String? ?? '0x0';
    final resolutionParts = resolution.split('x');
    final width = int.tryParse(resolutionParts.isNotEmpty ? resolutionParts[0] : '0') ?? 0;
    final height = int.tryParse(resolutionParts.length > 1 ? resolutionParts[1] : '0') ?? 0;

    return SegmentationResult(
      imageId: json['image_path'].hashCode.toString(),
      imagePath: json['image_path'] as String,
      width: width,
      height: height,
      objects: (json['objects'] as List)
          .map((obj) => SegmentedObject.fromJson(obj as Map<String, dynamic>))
          .toList(),
      segmentationDir: json['segmentation_dir'] as String,
      createdAt: DateTime.now(),
    );
  }
}

/// Requête de segmentation par prompt texte
class SegmentationRequest {
  final String imagePath;
  final String prompt;
  final double confidenceThreshold;
  final String? saveDir;

  const SegmentationRequest({
    required this.imagePath,
    required this.prompt,
    this.confidenceThreshold = 0.0,
    this.saveDir,
  });

  Map<String, dynamic> toJson() {
    return {
      'image_path': imagePath,
      'prompt': prompt,
      'confidence_threshold': confidenceThreshold,
      if (saveDir != null) 'save_dir': saveDir,
    };
  }
}

/// Point d'interaction pour SAM
class InteractivePoint {
  final double x; 
  final double y; 
  final bool isPositive; 

  const InteractivePoint({
    required this.x,
    required this.y,
    this.isPositive = true,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'label': isPositive ? 1 : 0,
  };
}
