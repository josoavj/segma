/// Configuration centralisée de l'application SEGMA
class AppConfig {
  /// URL de base du backend
  static const String backendUrl = 'http://localhost:8000';

  /// Dossier initial pour la navigation
  static const String initialFolder = '/home';

  /// Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration imageLoadTimeout = Duration(seconds: 10);

  /// Tailles
  static const int maxImageWidth = 4096;
  static const int maxImageHeight = 4096;

  /// Extensionstag des images supportées
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
  ];
}
