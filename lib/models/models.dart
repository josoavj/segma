import 'dart:typed_data';

class ImageModel {
  final String id;
  final String path;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;

  ImageModel({
    required this.id,
    required this.path,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
  });

  factory ImageModel.fromPath(String path, String name) {
    return ImageModel(
      id: path.hashCode.toString(),
      path: path,
      name: name,
      createdAt: DateTime.now(),
      sizeBytes: 0,
    );
  }
}

class FolderModel {
  final String id;
  final String path;
  final String name;
  final List<FolderModel> subfolders;
  final List<ImageModel> images;

  FolderModel({
    required this.id,
    required this.path,
    required this.name,
    this.subfolders = const [],
    this.images = const [],
  });

  factory FolderModel.root(String path) {
    return FolderModel(
      id: path.hashCode.toString(),
      path: path,
      name: path.split('/').last,
    );
  }
}

class SegmentationResult {
  final String imageId;
  final String imagePath;
  final Uint8List maskData;
  final int width;
  final int height;
  final double confidence;
  final DateTime createdAt;

  SegmentationResult({
    required this.imageId,
    required this.imagePath,
    required this.maskData,
    required this.width,
    required this.height,
    required this.confidence,
    required this.createdAt,
  });

  /// Retourne le masque comme une liste de booléens
  List<bool> getMaskAsBoolList() {
    final bytes = maskData;
    final boolList = <bool>[];
    for (var byte in bytes) {
      boolList.add(byte > 128);
    }
    return boolList;
  }

  /// Crée une nouvelle instance avec des données mises en cache
  SegmentationResult copyWith({
    String? imageId,
    String? imagePath,
    Uint8List? maskData,
    int? width,
    int? height,
    double? confidence,
    DateTime? createdAt,
  }) {
    return SegmentationResult(
      imageId: imageId ?? this.imageId,
      imagePath: imagePath ?? this.imagePath,
      maskData: maskData ?? this.maskData,
      width: width ?? this.width,
      height: height ?? this.height,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SegmentationRequest {
  final String imagePath;
  final int x;
  final int y;
  final int? boxX1;
  final int? boxY1;
  final int? boxX2;
  final int? boxY2;

  SegmentationRequest({
    required this.imagePath,
    required this.x,
    required this.y,
    this.boxX1,
    this.boxY1,
    this.boxX2,
    this.boxY2,
  });

  Map<String, dynamic> toJson() {
    return {
      'image_path': imagePath,
      'x': x,
      'y': y,
      if (boxX1 != null) 'box_x1': boxX1,
      if (boxY1 != null) 'box_y1': boxY1,
      if (boxX2 != null) 'box_x2': boxX2,
      if (boxY2 != null) 'box_y2': boxY2,
    };
  }
}
