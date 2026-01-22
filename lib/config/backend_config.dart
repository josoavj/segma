/// Configuration de l'application SEGMA
class AppConfig {
  // URLs du backend
  static const String backendUrl = 'http://localhost:8000';

  // Alternative pour développement sur device
  // static const String backendUrl = 'http://192.168.x.x:8000';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Configuration SAM 3
  static const String defaultPrompt = 'all objects';
  static const double defaultConfidenceThreshold = 0.25;

  // Modèle SAM 3 (unique - version stable)
  static const String sam3Model = 'facebook/sam3';
  static const String defaultModel = 'facebook/sam3';

  // Devices disponibles
  static const List<String> availableDevices = ['cpu', 'cuda'];
  static const String defaultDevice = 'cuda';

  // Descriptions SAM 3
  static const Map<String, String> modelDescriptions = {
    'facebook/sam3': 'SAM 3 - Segment Anything Model 3 (Mode PCS)',
  };

  static const Map<String, int> modelSizes = {
    'facebook/sam3': 2400, // Approximativement 2.4GB
  };
}
