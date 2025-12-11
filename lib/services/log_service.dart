import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class LogEntry {
  final String timestamp;
  final String level;
  final String message;
  final String? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() {
    return '[$timestamp] [$level] $message${stackTrace != null ? '\n$stackTrace' : ''}';
  }
}

class LogService {
  static final LogService _instance = LogService._internal();

  factory LogService() {
    return _instance;
  }

  LogService._internal();

  final List<LogEntry> _logs = [];
  late File _logFile;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final segmaDir = Directory('${appDocDir.path}/Segma');

      if (!await segmaDir.exists()) {
        await segmaDir.create(recursive: true);
      }

      final now = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd');
      final logFileName = 'segma_${dateFormat.format(now)}.log';

      _logFile = File('${segmaDir.path}/$logFileName');
      _initialized = true;

      info('=== Application Démarrée ===');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du LogService: $e');
    }
  }

  Future<void> _writeToFile(LogEntry entry) async {
    try {
      if (!_initialized) await initialize();
      await _logFile.writeAsString(
        '${entry.toString()}\n',
        mode: FileMode.append,
      );
    } catch (e) {
      debugPrint('Erreur lors de l\'écriture du log: $e');
    }
  }

  void debug(String message, {String? stackTrace}) {
    _addLog('DEBUG', message, stackTrace);
  }

  void info(String message, {String? stackTrace}) {
    _addLog('INFO', message, stackTrace);
  }

  void warning(String message, {String? stackTrace}) {
    _addLog('WARNING', message, stackTrace);
  }

  void error(String message, {String? stackTrace}) {
    _addLog('ERROR', message, stackTrace);
  }

  void _addLog(String level, String message, String? stackTrace) {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm:ss.SSS');
    final timestamp = timeFormat.format(now);

    final entry = LogEntry(
      timestamp: timestamp,
      level: level,
      message: message,
      stackTrace: stackTrace,
    );

    _logs.add(entry);
    _writeToFile(entry);

    // Garder seulement les 1000 derniers logs en mémoire
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }

    // Afficher aussi en debug console
    debugPrint(entry.toString());
  }

  List<LogEntry> getLogs({String? level, int limit = 100}) {
    List<LogEntry> filtered = _logs;

    if (level != null) {
      filtered = _logs.where((log) => log.level == level).toList();
    }

    return filtered
        .skip(filtered.length > limit ? filtered.length - limit : 0)
        .toList();
  }

  List<LogEntry> getAllLogs() => List.from(_logs);

  Future<String> getLogFilePath() async {
    if (!_initialized) await initialize();
    return _logFile.path;
  }

  Future<void> clearOldLogs({int daysToKeep = 7}) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final segmaDir = Directory('${appDocDir.path}/Segma');

      if (!await segmaDir.exists()) return;

      final now = DateTime.now();
      final entities = await segmaDir.list().toList();

      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          final diff = now.difference(stat.modified);

          if (diff.inDays > daysToKeep) {
            await entity.delete();
            info('Fichier log supprimé: ${entity.path}');
          }
        }
      }
    } catch (e) {
      error('Erreur lors de la suppression des anciens logs: $e');
    }
  }
}

// Instance globale
final logService = LogService();
