import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/services/backend_service.dart';
import 'package:segma/services/file_service.dart';
import 'package:segma/services/log_service.dart';
import 'package:segma/config/backend_config.dart';
import 'package:segma/services/folder_paths_service.dart';

/// Provider pour le service de Logs
final logServiceProvider = Provider<LogService>((ref) {
  return logService;
});

/// Provider pour le service Backend
final backendServiceProvider = Provider<BackendService>((ref) {
  return BackendService(baseUrl: AppConfig.backendUrl);
});

/// Provider pour le service de fichiers
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

/// Provider pour la résolution des chemins système
final folderPathsServiceProvider = Provider<FolderPathsService>((ref) {
  return FolderPathsService();
});
