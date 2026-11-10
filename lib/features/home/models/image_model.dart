class ImageModel {
  final String id;
  final String path;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;

  const ImageModel({
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
