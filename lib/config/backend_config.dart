import 'package:flutter/foundation.dart';

/// Configuration de l'application SEGMA pour la Production
class AppConfig {
  // L'URL est récupérée depuis les variables d'environnement au build ou utilise le défaut
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Timeouts adaptés à la production
  static const Duration apiTimeout = Duration(seconds: 45);
  static const Duration uploadTimeout = Duration(minutes: 10);

  // Configuration SAM 3
  static const String defaultPrompt = 'all objects';
  static const double defaultConfidenceThreshold = 0.25;

  static const String sam3Model = 'facebook/sam3';
  static const String defaultModel = 'facebook/sam3';

  static const List<String> availableDevices = ['cpu', 'cuda'];
  static const String defaultDevice = 'cuda';

  static const Map<String, String> modelDescriptions = {
    'facebook/sam3': 'SAM 3 - Segment Anything Model 3 (Mode PCS)',
  };

  static const Map<String, int> modelSizes = {
    'facebook/sam3': 2400, 
  };

  // Mode de l'application
  static bool get isProduction => kReleaseMode;
}
