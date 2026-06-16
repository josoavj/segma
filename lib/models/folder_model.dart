import 'image_model.dart';

class FolderModel {
  final String id;
  final String path;
  final String name;
  final List<FolderModel> subfolders;
  final List<ImageModel> images;

  const FolderModel({
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
