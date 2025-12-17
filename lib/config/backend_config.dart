/// Configuration de l'application SEGMA
class AppConfig {
  // URLs du backend
  static const String backendUrl = 'http://localhost:8000';

  // Alternative pour développement sur device
  // static const String backendUrl = 'http://192.168.x.x:8000';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Configuration SAM
  static const String defaultPrompt = 'all objects in the image';
  static const double defaultConfidenceThreshold = 0.0;

  // Modèles disponibles
  static const List<String> availableModels = ['vit_b', 'vit_l', 'vit_h'];
  static const String defaultModel = 'vit_b';

  // Devices disponibles
  static const List<String> availableDevices = ['cpu', 'cuda'];
  static const String defaultDevice = 'cpu';

  // Configurations des modèles
  static const Map<String, String> modelDescriptions = {
    'vit_b': 'Petit (96MB) - Rapide, idéal pour CPU',
    'vit_l': 'Moyen (312MB) - Équilibré',
    'vit_h': 'Grand (1.2GB) - Très précis, requiert GPU',
  };

  static const Map<String, int> modelSizes = {
    'vit_b': 96, // MB
    'vit_l': 312, // MB
    'vit_h': 1200, // MB
  };
}
